process DIAMOND_MAKEDB_TEST {
    label 'process_single'

    conda "${projectDir}/modules/nf-core/eggnogmapper/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eggnog-mapper:2.1.13--pyhdfd78af_2':
        'quay.io/biocontainers/eggnog-mapper:2.1.13--pyhdfd78af_2' }"

    input:
    path fasta

    output:
    path "eggnog_proteins.dmnd", emit: db

    script:
    """
    diamond makedb --in ${fasta} -d eggnog_proteins
    """
}
