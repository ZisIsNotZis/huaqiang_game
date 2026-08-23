class_name SaveRules
extends RefCounted

const EventState = preload("res://scripts/event_state.gd")
const CURRENT_VERSION := 1
const REQUIRED_FIELDS := [
	"phase",
	"turn",
	"short_mode",
	"facts",
	"witness_present",
	"witness_knowledge",
	"exit_prepared",
	"helper_blocked",
	"merchant_alert",
	"merchant_support",
	"available_actions",
	"log",
	"result",
	"player_condition",
	"epilogue_hook",
]
const VALID_PHASES := ["arrival", "prepare", "observe", "evidence", "pressure", "conflict", "resolved"]


static func encode(game: Dictionary) -> Dictionary:
	return {"version": CURRENT_VERSION, "game": game.duplicate(true)}


static func decode(raw: Variant) -> Dictionary:
	if not raw is Dictionary:
		return _failure("Checkpoint root must be an object.")
	var migrated: bool = not raw.has("version")
	var payload: Variant = raw if migrated else raw.get("game")
	if not migrated and raw.get("version") != CURRENT_VERSION:
		return _failure("Unsupported checkpoint version.")
	if not payload is Dictionary:
		return _failure("Checkpoint game data must be an object.")
	for field in REQUIRED_FIELDS:
		if not payload.has(field):
			return _failure("Checkpoint is missing '%s'." % field)
	if payload.phase not in VALID_PHASES:
		return _failure("Checkpoint phase is invalid.")
	if not payload.available_actions is Array or not payload.log is Array:
		return _failure("Checkpoint action or log data is invalid.")
	if not payload.result is Dictionary:
		return _failure("Checkpoint result data is invalid.")
	var normalized: Dictionary = payload.duplicate(true)
	var normalized_actions: Array = []
	for value in payload.available_actions:
		if not value is float and not value is int:
			return _failure("Checkpoint contains a non-numeric action.")
		var action := int(value)
		if action < EventState.Action.TALK_SISTER or action > EventState.Action.DESPERATE_ESCAPE:
			return _failure("Checkpoint contains an unknown action.")
		normalized_actions.append(action)
	normalized.available_actions = normalized_actions
	return {"ok": true, "game": normalized, "migrated": migrated, "error": ""}


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "game": {}, "migrated": false, "error": message}
