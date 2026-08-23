#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${project_root}/tools/godot_env.sh"

"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_event_state.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_interaction_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_perception_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_hearing_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_conflict_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_settings_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_audio_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_save_rules.gd
"${GODOT_BIN}" --headless --path "${project_root}" --script res://tests/test_runtime_usability.gd
