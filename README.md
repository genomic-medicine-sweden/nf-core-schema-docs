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
