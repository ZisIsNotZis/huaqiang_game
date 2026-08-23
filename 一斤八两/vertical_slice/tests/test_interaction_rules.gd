extends SceneTree

const EventState = preload("res://scripts/event_state.gd")
const InteractionRules = preload("res://scripts/interaction_rules.gd")


func _initialize() -> void:
	var game := EventState.create_game(true)
	var nearby := InteractionRules.available_nearby_actions(
		game.available_actions,
		Vector3(-1.4, 0.0, 0.7),
		{
			EventState.Action.INSPECT_SCALE: Vector3(-1.4, 0.0, 0.7),
			EventState.Action.INVITE_WITNESS: Vector3(8.2, 0.0, 3.0),
		},
		2.2,
	)
	assert(nearby == [EventState.Action.INSPECT_SCALE])

	nearby = InteractionRules.available_nearby_actions(
		game.available_actions,
		Vector3(7.2, 0.0, 3.0),
		{
			EventState.Action.INSPECT_SCALE: Vector3(-1.4, 0.0, 0.7),
			EventState.Action.INVITE_WITNESS: Vector3(8.2, 0.0, 3.0),
		},
		2.2,
	)
	assert(nearby == [EventState.Action.INVITE_WITNESS])

	var nearest := InteractionRules.nearest_available_action(
		[EventState.Action.INSPECT_SCALE, EventState.Action.ACCUSE_EARLY],
		Vector3(-1.4, 0.0, 0.8),
		{
			EventState.Action.INSPECT_SCALE: Vector3(-1.4, 0.0, 0.7),
			EventState.Action.ACCUSE_EARLY: Vector3(-1.5, 0.0, 1.8),
		},
		2.2,
	)
	assert(nearest == EventState.Action.INSPECT_SCALE)
	print("Godot interaction-rule tests passed.")
	quit()
