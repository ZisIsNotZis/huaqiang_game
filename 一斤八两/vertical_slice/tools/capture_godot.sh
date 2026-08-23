#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${project_root}/tools/godot_env.sh"

xvfb-run -a "${GODOT_BIN}" --path "${project_root}" -- --capture
xvfb-run -a "${GODOT_BIN}" --path "${project_root}" -- --capture-resolved
xvfb-run -a "${GODOT_BIN}" --path "${project_root}" -- --capture-injured
xvfb-run -a "${GODOT_BIN}" --path "${project_root}" -- --capture-highlight
xvfb-run -a "${GODOT_BIN}" --path "${project_root}" -- --capture-settings
