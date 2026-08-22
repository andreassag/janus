# Output

The pipeline produces the following output directory structure:

```text
results/
├── bakta/
│   └── <sample>/
│       ├── <prefix>.embl                   # EMBL format annotation
│       ├── <prefix>.gff3                   # GFF3 annotation
│       ├── <prefix>.gbff                   # GenBank annotation
│       ├── <prefix>.fna                    # Annotated nucleotide sequences
│       ├── <prefix>.ffn                    # Feature nucleotide sequences
│       ├── <prefix>.faa                    # Translated CDS sequences
│       ├── <prefix>.hypotheticals.faa      # Hypothetical protein sequences
│       ├── <prefix>.hypotheticals.tsv      # Hypothetical protein summary
│       ├── <prefix>.tsv                    # Tab-separated annotation summary
│       ├── <prefix>.json                   # Machine-readable JSON annotation
│       ├── <prefix>.txt                    # Human-readable annotation summary
│       ├── <prefix>.png                    # Genome plot (optional)
│       └── <prefix>.svg                    # Genome plot (optional)
├── eggnog/
│   └── <sample>/
│       ├── <prefix>.emapper.annotations    # Functional annotations
│       ├── <prefix>.emapper.seed_orthologs # Seed ortholog matches (optional)
│       └── <prefix>.emapper.hits           # Search hits (optional)
└── pipeline_info/
    ├── execution_timeline.html
    ├── execution_report.html
    ├── execution_trace.txt
    └── pipeline_dag.html
```

## bakta/

Full Bakta annotation output for each sample. Which annotation features are run is controlled by the skip flags in
`conf/advanced.config`.

## eggnog/

When `--eggnog_run true` (default), eggNOG-mapper runs on Bakta-generated protein FASTA files (`*.faa`) for each sample
using the diamond search mode. The annotations are written as `*.emapper.*` files under each sample directory.

## pipeline_info/

Nextflow execution reports: timeline, resource usage, trace log, and DAG visualization.
