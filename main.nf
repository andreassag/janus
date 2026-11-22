#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    andreassag/janus
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Bacterial genome annotation with Bakta and optional functional annotation with eggNOG-mapper.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'
include { BAKTA_ANNOTATE                       } from './workflows/bakta_annotate'

workflow {
    main:
    if (params.version) {
        log.info "${workflow.manifest.name} v${workflow.manifest.version}"
        exit(0)
    }

    if (params.help) {
        exit(0)
    }

    validateParameters()
    log.info paramsSummaryLog(workflow)

    BAKTA_ANNOTATE()
}
