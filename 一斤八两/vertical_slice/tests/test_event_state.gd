extends SceneTree

const EventState = preload("res://scripts/event_state.gd")


func _initialize() -> void:
	var game := EventState.create_game(true)
	game = EventState.perform_action(game, EventState.Action.INSPECT_SCALE)
	game = EventState.perform_action(game, EventState.Action.INVITE_WITNESS)
	game = EventState.perform_action(game, EventState.Action.ASK_FOR_WEIGHT)
	game = EventState.perform_action(game, EventState.Action.EXPOSE_MAGNET)
	assert(game.phase == "pressure")
	assert(game.merchant_support == 1)
	assert(game.available_actions == [EventState.Action.DEMAND_REFUND])
	game = EventState.perform_action(game, EventState.Action.DEMAND_REFUND)
	assert(game.result.outcome == "concession")
	assert(game.result.violence_started == false)

	var hidden_game := EventState.create_game(true)
	hidden_game = EventState.perform_action(
		hidden_game,
		EventState.Action.INSPECT_SCALE,
		{"observed": false},
	)
	assert(hidden_game.merchant_alert == 0)

	var seen_game := EventState.create_game(true)
	seen_game = EventState.perform_action(
		seen_game,
		EventState.Action.INSPECT_SCALE,
		{"observed": true},
	)
	assert(seen_game.merchant_alert == 1)

	var heard_game := EventState.create_game(true)
	heard_game = EventState.perform_action(
		heard_game,
		EventState.Action.BLOCK_HELPER_PATH,
		{"observed": false, "heard": true},
	)
	assert(heard_game.merchant_alert == 1)
	assert("摊主听见了木凳摩擦地面。" in heard_game.log[-1])

	var failed_game := EventState.create_game(true)
	failed_game = EventState.perform_action(failed_game, EventState.Action.ACCUSE_EARLY)
	assert(failed_game.phase == "conflict")
	assert(failed_game.available_actions == [EventState.Action.DESPERATE_ESCAPE])
	failed_game = EventState.perform_action(failed_game, EventState.Action.DESPERATE_ESCAPE)
	assert(failed_game.result.outcome == "injured_escape")
	assert(failed_game.result.injury == "severe")
	assert(failed_game.player_condition == "severe")

	var full_game := EventState.create_game()
	for action in [
		EventState.Action.TALK_SISTER,
		EventState.Action.REVIEW_PLAN,
		EventState.Action.CHOOSE_MELON,
		EventState.Action.ASK_GUARANTEE,
		EventState.Action.INSPECT_SCALE,
		EventState.Action.INVITE_WITNESS,
		EventState.Action.ASK_FOR_WEIGHT,
		EventState.Action.EXPOSE_MAGNET,
		EventState.Action.CUT_MELON,
		EventState.Action.DEMAND_REFUND,
	]:
		full_game = EventState.perform_action(full_game, action)
	assert(full_game.result.outcome == "concession")
	assert(full_game.epilogue_hook != "")

	var prepared_game := EventState.create_game()
	for action in [
		EventState.Action.TALK_SISTER,
		EventState.Action.REVIEW_PLAN,
		EventState.Action.PARK_FOR_EXIT,
		EventState.Action.BLOCK_HELPER_PATH,
		EventState.Action.ACCUSE_EARLY,
		EventState.Action.PUSH_AND_ESCAPE,
	]:
		prepared_game = EventState.perform_action(prepared_game, action)
	assert(prepared_game.result.outcome == "controlled_escape")
	assert(prepared_game.result.injury == "none")
	print("Godot event-state tests passed.")
	quit()
