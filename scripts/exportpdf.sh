#!/usr/bin/env bash
set -e

curl -L \
  "https://docs.google.com/document/d/${DOC_ID}/export?format=pdf" \
  -o static/files/resume.pdf