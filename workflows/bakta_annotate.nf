/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    BAKTA_ANNOTATE workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Annotate bacterial genomes with Bakta.
    Per-sample settings via samplesheet columns: complete, gram, locus_prefix.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BAKTA_BAKTA             } from '../modules/nf-core/bakta/bakta/main'
include { BAKTA_BAKTADBDOWNLOAD   } from '../modules/nf-core/bakta/baktadbdownload/main'
include { EGGNOG_DOWNLOADDATABASE } from '../modules/local/eggnogdownloaddatabase/main'
include { EGGNOGMAPPER            } from '../modules/nf-core/eggnogmapper/main'

workflow BAKTA_ANNOTATE {

    // ── Parse and validate samplesheet ──────────────────────────────────────
    //
    // Required columns : sample, fasta
    // Optional columns : complete, gram, locus_prefix
    //
    channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true, strip: true)
        .map { row ->
            if (!row.fasta) {
                error("ERROR: 'fasta' column is required for sample '${row.sample}'")
            }

            def prefix   = row.locus_prefix ?: row.sample
            def gram     = (row.gram && row.gram.trim()) ? row.gram.trim() : '?'
            def complete = row.complete?.toLowerCase() in ['true', '1', 'yes']

            def meta = [id: row.sample, prefix: prefix, gram: gram, complete: complete]

            def fasta = file(row.fasta)
            if (!fasta.exists()) {
                fasta = file("${projectDir}/${row.fasta}")
            }
            if (!fasta.exists()) {
                fasta = file("${file(params.input).parent}/${row.fasta}")
            }
            if (!fasta.exists()) {
                error("ERROR: FASTA file not found for sample '${row.sample}': ${row.fasta}")
            }

            return [meta, fasta]
        }
        .set { ch_samples }

    // ── Download / reuse databases ──────────────────────────────────────────
    //   Bakta   → <bakta_db_dir>
    //   eggNOG  → <eggnog_db_dir>
    if (params.bakta_db) {
        ch_bakta_db = channel.fromPath(params.bakta_db, checkIfExists: true).collect()
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

    if (params.eggnog_run) {
        if (params.eggnog_db) {
            ch_eggnog_db = channel.fromPath(params.eggnog_db, checkIfExists: true).collect()
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
    }
}
