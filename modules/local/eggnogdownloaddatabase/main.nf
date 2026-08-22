process EGGNOG_DOWNLOADDATABASE {
    tag "eggnog_db"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eggnog-mapper:2.1.13--pyhdfd78af_2':
        'quay.io/biocontainers/eggnog-mapper:2.1.13--pyhdfd78af_2' }"

    output:
    path "eggnog_data/", emit: db

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p eggnog_data

    download_eggnog_data.py \\
        -y \\
        --data_dir eggnog_data \\
        ${args}
    """

    stub:
    """
    mkdir -p eggnog_data
    touch eggnog_data/eggnog.db
    touch eggnog_data/eggnog.taxa.db
    touch eggnog_data/eggnog_proteins.dmnd
    touch eggnog_data/.download_complete
    """
}
