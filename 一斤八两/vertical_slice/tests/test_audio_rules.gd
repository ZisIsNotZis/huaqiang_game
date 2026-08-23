extends SceneTree

const EventState = preload("res://scripts/event_state.gd")
const AudioRules = preload("res://scripts/audio_rules.gd")


func _initialize() -> void:
	var inspect := AudioRules.profile_for_action(EventState.Action.INSPECT_SCALE)
	assert(inspect.frequency == 320.0)
	assert(inspect.duration == 0.08)

	var cut := AudioRules.profile_for_action(EventState.Action.CUT_MELON)
	assert(cut.frequency == 110.0)
	assert(cut.duration == 0.22)
	print("Godot audio-rule tests passed.")
	quit()
