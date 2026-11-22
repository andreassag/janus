# janus

**janus** is a [Nextflow](https://www.nextflow.io/) pipeline for bacterial genome annotation using
[Bakta](https://github.com/oschwengers/bakta) with optional functional annotation via
[eggNOG-mapper](https://github.com/eggnogdb/eggnog-mapper).

## Features

- Batch annotation of bacterial genomes via a validated CSV samplesheet (`nf-schema`)
- Per-sample configuration of genome completeness, Gram stain, and locus tag prefix
- Standardized [nf-core](https://nf-co.re/) modules for Bakta annotation, database downloads, and eggNOG-mapper
- Automatic Bakta database download and cache reuse when no local database is provided
- Optional eggNOG-mapper functional annotation from Bakta protein FASTA outputs
- Automatic eggNOG database download and cache reuse when no local database is provided
- Automated software version tracking (`pipeline_info/software_versions.yml`)

## Requirements

- [Nextflow](https://www.nextflow.io/) >= 25.10.0 (Java 17+)
- [Docker](https://www.docker.com/), [Singularity](https://sylabs.io/singularity/), [Apptainer](https://apptainer.org/),
  [Podman](https://podman.io/), or [Conda](https://docs.conda.io/)

## Quick start

```bash
nextflow run andreassag/janus \
    --input assets/samplesheet.csv \
    --outdir results \
    -profile docker
```

## Input

A CSV samplesheet with columns:

| Column         | Required | Description                                                   |
| -------------- | -------- | ------------------------------------------------------------- |
| `sample`       | Yes      | Unique sample identifier (no spaces)                          |
| `fasta`        | Yes      | Path to genome FASTA file (`.fa`, `.fas`, `.fna`, `.fasta`)   |
| `complete`     | No       | `true` if genome is fully assembled (default: `false`)        |
| `gram`         | No       | Gram stain: `+`, `-`, or `?` (default: `?`)                   |
| `locus_prefix` | No       | Prefix for locus tags and output files (default: sample name) |

Example:

```csv
sample,fasta,complete,gram,locus_prefix
ecoli_k12,genomes/ecoli.fasta,true,-,ECK
staph_aureus,genomes/s_aureus.fasta,false,+,SAU
```

## Key parameters

| Parameter         | Default                      | Description                                          |
| ----------------- | ---------------------------- | ---------------------------------------------------- |
| `--input`         | _required_                   | Path to samplesheet CSV                              |
| `--outdir`        | `results`                    | Output directory                                     |
| `--bakta_db`      | `null`                       | Path to existing Bakta database directory            |
| `--bakta_db_dir`  | `${launchDir}/.janus/bakta`  | Directory for Bakta database (downloaded if absent)  |
| `--bakta_db_type` | `full`                       | Bakta database type to download (`full` or `light`)  |
| `--eggnog_run`    | `true`                       | Run eggNOG-mapper on Bakta protein FASTA files       |
| `--eggnog_db`     | `null`                       | Path to existing eggNOG database directory           |
| `--eggnog_db_dir` | `${launchDir}/.janus/eggnog` | Directory for eggNOG database (downloaded if absent) |

## Output

```text
results/
├── bakta/
│   └── <sample>/          # Full Bakta output per sample
│       ├── <prefix>.embl
│       ├── <prefix>.gff3
│       ├── <prefix>.gbff
│       ├── <prefix>.fna
│       ├── <prefix>.faa
│       ├── <prefix>.ffn
│       ├── <prefix>.hypotheticals.faa
│       ├── <prefix>.hypotheticals.tsv
│       ├── <prefix>.tsv
│       ├── <prefix>.json
│       └── <prefix>.txt
├── eggnog/
│   └── <sample>/          # eggNOG-mapper output per sample
│       └── <prefix>.emapper.*
└── pipeline_info/         # Execution reports and software_versions.yml
```

## Profiles

| Profile       | Description                                    |
| ------------- | ---------------------------------------------- |
| `docker`      | Run with Docker containers                     |
| `singularity` | Run with Singularity containers                |
| `apptainer`   | Run with Apptainer containers                  |
| `podman`      | Run with Podman containers                     |
| `conda`       | Run with Conda environments                    |
| `test`        | Compact 2-sample bacterial test dataset        |
| `test_full`   | Full 3-genome bacterial reference test dataset |

## Documentation

Full documentation is available at [https://andreassag.github.io/janus](https://andreassag.github.io/janus).

## Citations

If you use janus in your research, please cite the tools it wraps. See [CITATIONS.md](CITATIONS.md).

## License

[MIT](LICENSE)
