# Contributing

Contributions are welcome. This document describes how to set up a development environment and the conventions the
project follows.

---

## Development setup

```bash
git clone https://github.com/andreassag/janus.git
cd janus

# Create a Python virtual environment (Python 3.11+)
python -m venv .venv
source .venv/bin/activate

# Install development tools
pip install pre-commit

# Activate native git hooks in the repository
git config core.hooksPath .githooks

# Or install Python pre-commit hooks
pip install pre-commit && pre-commit install
```

---

## Code style

### Nextflow (`.nf`, `.config`)

Nextflow files are formatted with [Prettier](https://prettier.io/) via `prettier-plugin-groovy`.

---

## Git hooks (`.githooks/`)

The repository includes pre-configured Git hooks in the `.githooks/` directory:

| Hook         | Purpose                                                   |
| ------------ | --------------------------------------------------------- |
| `pre-commit` | Validates EditorConfig compliance and Prettier formatting |

Activate the hooks:

```bash
git config core.hooksPath .githooks
```

Run checks manually:

```bash
.githooks/pre-commit
```

---

## Managing nf-core modules

Modules are installed from [nf-core/modules](https://github.com/nf-core/modules):

```bash
# List installed modules
nf-core modules list local

# Install a new module
nf-core modules install <tool>/<subtool>

# Update modules
nf-core modules update
```

---

## Testing

### nf-test (Nextflow unit tests)

```bash
# requires Nextflow and Docker
nf-test test tests/ --verbose
```

### Full pipeline test

```bash
nextflow run . \
    --input assets/samplesheet.csv \
    --outdir results \
    -profile test,docker \
    -stub-run
```

---

## Branching and pull requests

- `main` is the stable release branch.
- Feature branches: `feature/<description>`
- Bug/hot fixes: `fix/<description>`
- Non-code tasks: `chore/<description>`
- Preparing a release: `release/<description>`
- Open a pull request against `main`; CI must be green before merge.

---

## Releases

Releases follow [Semantic Versioning](https://semver.org/). To cut a release:

1. Update the version in `nextflow.config` (`manifest.version`).
2. Commit with message `release: bump version to X.Y.Z`.
3. Push a `X.Y.Z` tag — the `release.yml` workflow creates the GitHub Release automatically.

```bash
git tag 1.1.0
git push origin 1.1.0
```
