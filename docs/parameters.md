# Parameters

## Input/output options

| Parameter  | Default    | Description                                       |
| ---------- | ---------- | ------------------------------------------------- |
| `--input`  | _required_ | Path to CSV samplesheet (sample, fasta required). |
| `--outdir` | `results`  | Output directory for results.                     |

## Database options

Both databases are downloaded automatically on first run and reused on subsequent runs. Point these to shared storage on
HPC systems or specify pre-downloaded database paths.

| Parameter         | Default                      | Description                                                  |
| ----------------- | ---------------------------- | ------------------------------------------------------------ |
| `--bakta_db`      | `null`                       | Path to existing Bakta database directory.                   |
| `--bakta_db_dir`  | `${launchDir}/.janus/bakta`  | Directory where the Bakta database is stored or downloaded.  |
| `--bakta_db_type` | `full`                       | Type of Bakta database to download (`full` or `light`).      |
| `--eggnog_db`     | `null`                       | Path to existing eggNOG database directory.                  |
| `--eggnog_db_dir` | `${launchDir}/.janus/eggnog` | Directory where the eggNOG database is stored or downloaded. |

## Bakta options

Per-sample settings (`complete`, `gram`, `locus_prefix`) are set via samplesheet columns, not pipeline parameters.

| Parameter            | Default | Description                                            |
| -------------------- | ------- | ------------------------------------------------------ |
| `--bakta_proteins`   | `null`  | Path to FASTA/GenBank file of trusted proteins.        |
| `--bakta_regions`    | `null`  | Path to GFF3 or GenBank file of pre-annotated regions. |
| `--bakta_hmms`       | `null`  | Path to custom HMM file for CDS annotation.            |
| `--bakta_extra_args` | `""`    | Additional CLI arguments passed directly to bakta.     |

## eggNOG-mapper options

| Parameter              | Default   | Description                                                          |
| ---------------------- | --------- | -------------------------------------------------------------------- |
| `--eggnog_run`         | `true`    | Run eggNOG-mapper on Bakta protein FASTA outputs (faa).              |
| `--eggnog_search_mode` | `diamond` | Search method: diamond, mmseqs, hmmer, no_search, cache, novel_fams. |
| `--eggnog_dmnd_db`     | `null`    | Path to custom Diamond database file (\*.dmnd).                      |
| `--eggnog_extra_args`  | `""`      | Additional CLI arguments passed verbatim to emapper.py.              |

## Generic options

| Parameter            | Default | Description                                         |
| -------------------- | ------- | --------------------------------------------------- |
| `--publish_dir_mode` | `copy`  | Method used to save pipeline results to output dir. |
| `--monochrome_logs`  | `false` | Disable coloured log output.                        |
| `--help`             | `false` | Display help text.                                  |
| `--version`          | `false` | Display version and exit.                           |
