#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "README.md"
  "CONTRIBUTING.md"
  "dev_plan.md"
  "docs/project-charter.md"
  "docs/originality-and-ip.md"
  "docs/risk-register.md"
  "docs/decision-register.md"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -s "${project_root}/${relative_path}" ]]; then
    printf 'Missing or empty Phase 0 file: %s\n' "${relative_path}" >&2
    exit 1
  fi
done

if grep -RInE \
  --include='*.md' \
  '(已获得[^[:cntrl:]]*官方授权|已完成[^[:cntrl:]]*外部融资|已完成[^[:cntrl:]]*外部玩家测试)' \
  "${project_root}"; then
  printf 'Project documents contain an unverified external claim.\n' >&2
  exit 1
fi

printf 'Phase 0 repository checks passed.\n'
printf 'Phase 0 owner constraints are recorded for the private project.\n'
