#!/usr/bin/env sh
set -e

git config --global user.email "ci@gitlab.com"
git config --global user.name "gitlab-ci"
git checkout -B pdf-update
git add hugo/static/files/louieladiona_resume.pdf

if git diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

git commit -m "chore: update resume PDF [CI]"
git push https://oauth2:${GITLAB_TOKEN}@gitlab.com/${CI_PROJECT_PATH}.git pdf-update