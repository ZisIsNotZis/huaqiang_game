#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "docs/phase-1-concept.md"
  "docs/phase-1-owner-test.md"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -s "${project_root}/${relative_path}" ]]; then
    printf 'Missing or empty Phase 1 file: %s\n' "${relative_path}" >&2
    exit 1
  fi
done

required_terms=(
  "核心假设"
  "范围梯度"
  "Conditional Go"
  "不证明市场需求"
)

for term in "${required_terms[@]}"; do
  if ! grep -q "${term}" "${project_root}/docs/phase-1-concept.md" \
    && ! grep -q "${term}" "${project_root}/docs/phase-1-owner-test.md"; then
    printf 'Phase 1 evidence is missing required term: %s\n' "${term}" >&2
    exit 1
  fi
done

printf 'Phase 1 concept and private-project gate checks passed.\n'
printf 'Owner answers remain a design input, not an external validation claim.\n'
