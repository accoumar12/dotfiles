#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: git search-history <string>"
  exit 1
fi

search_string="$1"

git rev-list --all | (
  while read -r revision; do
    git grep -F "$search_string" "$revision"
  done
)

