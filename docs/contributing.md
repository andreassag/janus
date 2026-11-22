# Contributing

Contributions are welcome. This document describes how to set up a development environment and the conventions the
project follows.

---

## Development setup

```bash
git clone https://github.com/andreassag/janus.git
cd janus

# Install Node.js formatting/linting tools
npm ci

# Install pre-commit hooks (requires pre-commit)
pre-commit install
```

---

## Code style and linting

- **Nextflow (`.nf`, `.config`)**: Validated with `nextflow lint .` and `nf-core modules lint --all`.
- **JSON, YAML, Markdown**: Formatted with [Prettier](https://prettier.io/) and checked with `editorconfig-checker`:

```bash
npm run lint
npm run format
pre-commit run --all-files
```

---

## Managing nf-core modules

Modules are installed from [nf-core/modules](https://github.com/nf-core/modules):

```bash
# List installed modules
nf-core modules list local

# Install a new module
nf-core modules install <tool>/<subtool>

# Update modules and lint
nf-core modules update --all
nf-core modules lint --all
```

---

## Testing

### nf-test (tiered unit, workflow, and pipeline tests)

```bash
# Tier 1: Fast stub tests (modules, workflow wiring, CLI, failure paths)
nf-test test tests/ --tag stub --verbose

# Tier 2: Real containerized pipeline tests (Docker)
nf-test test tests/pipeline_real.nf.test --profile docker --verbose
```

### Direct Nextflow pipeline runs

```bash
# Compact 2-sample test profile (stub)
nextflow run . -profile test,docker -stub-run

# Full 3-genome reference profile (stub)
nextflow run . -profile test_full,docker -stub-run
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

1. Update the version in `nextflow.config` (`manifest.version`) and `package.json`.
2. Commit with message `release: bump version to X.Y.Z`.
3. Push a `X.Y.Z` tag — the `release.yml` workflow creates the GitHub Release automatically.

```bash
git tag 1.1.0
git push origin 1.1.0
```
