# `nf-core pipelines schema docs` pre-commit hook

A pre-commit hook for running `nf-core pipelines schema docs` for non nf-core pipelines.

## Installation 

- [nf-core](https://github.com/nf-core/tools) installed and available in your `PATH`
- [pre-commit](https://pre-commit.com/) installed

## Setup

1. Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/genomic-medicine-sweden/nf-core-schema-docs
    rev: v0.1.0  # Use the latest release tag
    hooks:
      - id: nf-core-schema-docs
```

2. Install the hook:

```bash
pre-commit install
```

The hook will now run `nf-core pipelines schema docs` if `nextflow_schema.json` is staged when you commit.

## Configuration

By default, the output file will be `docs/parameters.md`, change this via `args`:

```yaml
hooks:
  - id: nf-core-schema-docs
    args: ["pipeline_docs/params.md"]
```

Pre-commit in `.github/workflows/linting.yml` will now require Nextflow and nf-core. For efficiency, it might be best to update `.github/workflows/linting.yml` to combine the `pre-commit` and `nf-core` jobs into one to avoid setting up the same dependencies twice: 

```yaml
name: nf-core linting
# This workflow is triggered on pushes and PRs to the repository.
# It runs the `nf-core pipelines lint` and markdown lint tests to ensure
# that the code meets the nf-core guidelines.
on:
  pull_request:
  release:
    types: [published]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Check out pipeline code
        uses: actions/checkout@93cb6efe18208431cddfb8368fd83d5badbf9bfd # v5

      - name: Install Nextflow
        uses: nf-core/setup-nextflow@v2

      - uses: actions/setup-python@e797f83bcb11b83ae66e0230d6156d7c80228e7c # v6
        with:
          python-version: "3.14"
          architecture: "x64"

      - name: read .nf-core.yml
        uses: pietrobolcato/action-read-yaml@9f13718d61111b69f30ab4ac683e67a56d254e1d # 1.1.0
        id: read_yml
        with:
          config: ${{ github.workspace }}/.nf-core.yml

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install pre-commit
          pip install nf-core==${{ steps.read_yml.outputs['nf_core_version'] }}

      - name: Run pre-commit
        run: pre-commit run --all-files

      - name: Run nf-core pipelines lint
        if: ${{ github.base_ref != 'master' }}
        env:
          GITHUB_COMMENTS_URL: ${{ github.event.pull_request.comments_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_PR_COMMIT: ${{ github.event.pull_request.head.sha }}
        run: nf-core -l lint_log.txt pipelines lint --dir ${GITHUB_WORKSPACE} --markdown lint_results.md

      - name: Run nf-core pipelines lint --release
        if: ${{ github.base_ref == 'master' }}
        env:
          GITHUB_COMMENTS_URL: ${{ github.event.pull_request.comments_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_PR_COMMIT: ${{ github.event.pull_request.head.sha }}
        run: nf-core -l lint_log.txt pipelines lint --release --dir ${GITHUB_WORKSPACE} --markdown lint_results.md

      - name: Save PR number
        if: ${{ always() }}
        run: echo ${{ github.event.pull_request.number }} > PR_number.txt

      - name: Upload linting log file artifact
        if: ${{ always() }}
        uses: actions/upload-artifact@330a01c490aca151604b8cf639adc76d48f6c5d4 # v5
        with:
          name: linting-logs
          path: |
            lint_log.txt
            lint_results.md
            PR_number.txt
```
