extends SceneTree

const ConflictRules = preload("res://scripts/conflict_rules.gd")


func _initialize() -> void:
	var controlled := ConflictRules.resolve_escape(true, true, 3)
	assert(controlled.outcome == "controlled_escape")
	assert(controlled.injury == "none")

	var exposed := ConflictRules.resolve_escape(true, false, 3)
	assert(exposed.outcome == "injured_escape")
	assert(exposed.injury == "minor")

	var trapped := ConflictRules.resolve_escape(false, false, 3)
	assert(trapped.outcome == "injured_escape")
	assert(trapped.injury == "severe")
	print("Godot conflict-rule tests passed.")
	quit()
