extends SceneTree

const EventState = preload("res://scripts/event_state.gd")
const SaveRules = preload("res://scripts/save_rules.gd")


func _initialize() -> void:
	var game := EventState.create_game()
	game = EventState.perform_action(game, EventState.Action.TALK_SISTER)
	var decoded := SaveRules.decode(SaveRules.encode(game))
	assert(decoded.ok)
	assert(decoded.game.phase == "prepare")
	assert(decoded.game.available_actions == [EventState.Action.REVIEW_PLAN])

	var legacy := SaveRules.decode(game)
	assert(legacy.ok)
	assert(legacy.migrated)

	var corrupt := SaveRules.decode({"version": 1, "game": {"phase": "observe"}})
	assert(not corrupt.ok)
	assert("missing" in corrupt.error)

	var future := SaveRules.decode({"version": 99, "game": game})
	assert(not future.ok)
	assert("Unsupported" in future.error)
	print("Godot save-rule tests passed.")
	quit()
