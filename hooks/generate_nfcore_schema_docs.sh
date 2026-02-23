#!/usr/bin/env bash
set -euo pipefail

SCHEMA="nextflow_schema.json"
DOCS="${1:-docs/parameters.md}"

if [ ! -f "$SCHEMA" ]; then
  echo "No nextflow_schema.json found. Skipping."
  exit 0
fi

echo "Generating nf-core parameter documentation: $DOCS"
nf-core pipelines schema docs -o $DOCS --force

if ! git diff --quiet "$DOCS"; then
  echo "Schema docs updated."
  git add "$DOCS"
fi
