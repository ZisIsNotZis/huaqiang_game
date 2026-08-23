#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${project_root}/tools/godot_env.sh"

mkdir -p "${project_root}/build"
"${GODOT_BIN}" --headless --path "${project_root}" --export-release "Linux/X11"
