class_name AudioRules
extends RefCounted

const EventState = preload("res://scripts/event_state.gd")


static func profile_for_action(action: EventState.Action) -> Dictionary:
	match action:
		EventState.Action.INSPECT_SCALE:
			return {"frequency": 320.0, "duration": 0.08, "gain": 0.12}
		EventState.Action.BLOCK_HELPER_PATH:
			return {"frequency": 72.0, "duration": 0.28, "gain": 0.24}
		EventState.Action.CUT_MELON:
			return {"frequency": 110.0, "duration": 0.22, "gain": 0.32}
		EventState.Action.ACCUSE_EARLY, EventState.Action.DEMAND_REFUND:
			return {"frequency": 180.0, "duration": 0.16, "gain": 0.2}
		EventState.Action.PUSH_AND_ESCAPE, EventState.Action.DESPERATE_ESCAPE:
			return {"frequency": 58.0, "duration": 0.35, "gain": 0.35}
		_:
			return {"frequency": 240.0, "duration": 0.1, "gain": 0.1}
