/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    BAKTA_ANNOTATE workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Annotate bacterial genomes with Bakta and optionally eggNOG-mapper.
    Per-sample settings via samplesheet columns: complete, gram, locus_prefix.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { samplesheetToList       } from 'plugin/nf-schema'
include { BAKTA_BAKTA             } from '../modules/nf-core/bakta/bakta/main'
include { BAKTA_BAKTADBDOWNLOAD   } from '../modules/nf-core/bakta/baktadbdownload/main'
include { EGGNOG_DOWNLOADDATABASE } from '../modules/local/eggnogdownloaddatabase/main'
include { EGGNOGMAPPER            } from '../modules/nf-core/eggnogmapper/main'

def resolveExistingBaktaDb(String baseDir, String dbType) {
    def candidates = dbType == 'light'
        ? [file("${baseDir}/db-light"), file("${baseDir}/db"), file(baseDir)]
        : [file("${baseDir}/db"), file(baseDir)]
    return candidates.find { dir -> file("${dir}/bakta.db").exists() }
}

def resolveExistingEggnogDb(String baseDir) {
    def candidates = [file("${baseDir}/eggnog_data"), file(baseDir)]
    return candidates.find { dir -> file("${dir}/eggnog.db").exists() }
}

def resolveSampleFasta(String rawPath, String inputSheet) {
    def candidates = [
        file(rawPath),
        file("${projectDir}/${rawPath}"),
        file("${file(inputSheet).parent}/${rawPath}")
    ]
    def found = candidates.find { candidate -> candidate.exists() }
    if (!found) {
        error("ERROR: FASTA file not found: ${rawPath}")
    }
    return found
}

workflow BAKTA_ANNOTATE {

    main:
    if (!params.input) {
        error("ERROR: An input samplesheet must be provided via --input")
    }

    // ── Parse and validate samplesheet ──────────────────────────────────────
    //
    // Required columns : sample, fasta
    // Optional columns : complete, gram, locus_prefix
    //
    def ch_samples = channel
        .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))
        .map { meta_in, raw_fasta ->
            def prefix   = (meta_in.prefix && meta_in.prefix.toString().trim()) ? meta_in.prefix.toString().trim() : meta_in.id.toString()
            def gram     = (meta_in.gram && meta_in.gram.toString().trim()) ? meta_in.gram.toString().trim() : '?'
            def complete = meta_in.complete instanceof Boolean
                ? meta_in.complete
                : (meta_in.complete?.toString()?.trim()?.toLowerCase() in ['true', '1', 'yes'])

            def meta  = [id: meta_in.id.toString(), prefix: prefix, gram: gram, complete: complete]
            def fasta = resolveSampleFasta(raw_fasta.toString(), params.input.toString())

            return [meta, fasta]
        }

    // ── Download / reuse Bakta database ─────────────────────────────────────
    def cached_bakta_db = (!params.bakta_db && params.bakta_db_dir)
        ? resolveExistingBaktaDb(params.bakta_db_dir.toString(), params.bakta_db_type.toString())
        : null

    if (params.bakta_db) {
        ch_bakta_db = channel.fromPath(params.bakta_db, checkIfExists: true).first()
    } else if (cached_bakta_db) {
        log.info "Using cached Bakta database at: ${cached_bakta_db}"
        ch_bakta_db = channel.fromPath(cached_bakta_db, checkIfExists: true).first()
    } else {
        BAKTA_BAKTADBDOWNLOAD()
        ch_bakta_db = BAKTA_BAKTADBDOWNLOAD.out.db
    }

    // ── Run Bakta ───────────────────────────────────────────────────────────
    ch_proteins    = params.bakta_proteins ? file(params.bakta_proteins, checkIfExists: true) : []
    ch_prodigal_tf = params.bakta_prodigal_tf ? file(params.bakta_prodigal_tf, checkIfExists: true) : []
    ch_regions     = params.bakta_regions ? file(params.bakta_regions, checkIfExists: true) : []
    ch_hmms        = params.bakta_hmms ? file(params.bakta_hmms, checkIfExists: true) : []

    BAKTA_BAKTA(
        ch_samples,
        ch_bakta_db,
        ch_proteins,
        ch_prodigal_tf,
        ch_regions,
        ch_hmms
    )

    // ── Optionally run eggNOG-mapper ────────────────────────────────────────
    if (params.eggnog_run) {
        def cached_eggnog_db = (!params.eggnog_db && params.eggnog_db_dir)
            ? resolveExistingEggnogDb(params.eggnog_db_dir.toString())
            : null

        if (params.eggnog_db) {
            ch_eggnog_db = channel.fromPath(params.eggnog_db, checkIfExists: true).first()
        } else if (cached_eggnog_db) {
            log.info "Using cached eggNOG database at: ${cached_eggnog_db}"
            ch_eggnog_db = channel.fromPath(cached_eggnog_db, checkIfExists: true).first()
        } else {
            EGGNOG_DOWNLOADDATABASE()
            ch_eggnog_db = EGGNOG_DOWNLOADDATABASE.out.db
        }

        ch_search_mode_db = channel.value([
            params.eggnog_search_mode,
            params.eggnog_dmnd_db ? file(params.eggnog_dmnd_db, checkIfExists: true) : []
        ])

        EGGNOGMAPPER(
            BAKTA_BAKTA.out.faa,
            ch_search_mode_db,
            ch_eggnog_db
        )

        ch_eggnog_annotations = EGGNOGMAPPER.out.annotations
        ch_eggnog_orthologs   = EGGNOGMAPPER.out.orthologs
        ch_eggnog_hits        = EGGNOGMAPPER.out.hits
    } else {
        ch_eggnog_annotations = channel.empty()
        ch_eggnog_orthologs   = channel.empty()
        ch_eggnog_hits        = channel.empty()
    }

    // ── Collect software versions ───────────────────────────────────────────
    ch_software_versions = channel.topic('versions')
        .toList()
        .map { entries ->
            def grouped = [:].withDefault { [:] }
            entries.each { proc, tool, ver ->
                def procName = proc.toString().tokenize(':').last()
                grouped[procName][tool.toString()] = (ver ?: 'unknown').toString().trim()
            }
            grouped['Workflow'] = [
                (workflow.manifest.name): workflow.manifest.version.toString(),
                'Nextflow'              : workflow.nextflow.version.toString()
            ]
            grouped
                .sort { a, b -> a.key <=> b.key }
                .collect { procName, tools ->
                    def toolLines = tools
                        .sort { a, b -> a.key <=> b.key }
                        .collect { tool, ver -> "  ${tool}: \"${ver}\"" }
                        .join('\n')
                    "${procName}:\n${toolLines}\n"
                }
                .join('')
        }
        .collectFile(name: 'software_versions.yml', storeDir: "${params.outdir}/pipeline_info", newLine: false)

    emit:
    bakta_embl             = BAKTA_BAKTA.out.embl
    bakta_faa              = BAKTA_BAKTA.out.faa
    bakta_ffn              = BAKTA_BAKTA.out.ffn
    bakta_fna              = BAKTA_BAKTA.out.fna
    bakta_gbff             = BAKTA_BAKTA.out.gbff
    bakta_gff              = BAKTA_BAKTA.out.gff
    bakta_hypotheticals_tsv = BAKTA_BAKTA.out.hypotheticals_tsv
    bakta_hypotheticals_faa = BAKTA_BAKTA.out.hypotheticals_faa
    bakta_tsv              = BAKTA_BAKTA.out.tsv
    bakta_txt              = BAKTA_BAKTA.out.txt
    bakta_json             = BAKTA_BAKTA.out.json
    eggnog_annotations     = ch_eggnog_annotations
    eggnog_orthologs       = ch_eggnog_orthologs
    eggnog_hits            = ch_eggnog_hits
    versions               = ch_software_versions
}
