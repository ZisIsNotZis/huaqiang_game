#!/usr/bin/env bash

if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]]; then
  return
fi

session_godot="/home/z/.copilot/session-state/6c00a3f9-b5c0-4d01-929a-5be349e1da26/files/godot-4.7.1/Godot_v4.7.1-stable_linux.x86_64"
if [[ -x "${session_godot}" ]]; then
  GODOT_BIN="${session_godot}"
  export GODOT_BIN
  return
fi

printf 'Set GODOT_BIN to a Godot 4.7.1 executable.\n' >&2
exit 1
