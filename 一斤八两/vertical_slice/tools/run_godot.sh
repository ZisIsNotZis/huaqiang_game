#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${project_root}/tools/godot_env.sh"

"${GODOT_BIN}" --path "${project_root}"
