#!/usr/bin/env bash
set -e

echo "Exporting resume from Google Docs as PDF..."

DEPLYMENT=$(eval git diff HEAD^ HEAD -- hugo/static/files/)
if [[ -n "$DEPLYMENT" ]]; then # it execute only if the commit have changes in the hugo/static/files/ directory
  echo "Changes detected in hugo/static/files/. Exporting PDF..."
  curl -L \
    "https://docs.google.com/document/d/${DOC_ID}/export?format=pdf" \
    -o hugo/static/files/louieladiona_resume.pdf
else
  echo "No changes detected" 
fi
