extends SceneTree

const PerceptionRules = preload("res://scripts/perception_rules.gd")


func _initialize() -> void:
	var visible := PerceptionRules.evaluate_sight(
		Vector3(0, 0, 0),
		Vector3(0, 0, -1),
		Vector3(0, 0, -4),
		7.0,
		80.0,
		false,
	)
	assert(visible.seen == true)
	assert(visible.reason == "目标位于视野内")

	var behind := PerceptionRules.evaluate_sight(
		Vector3(0, 0, 0),
		Vector3(0, 0, -1),
		Vector3(0, 0, 3),
		7.0,
		80.0,
		false,
	)
	assert(behind.seen == false)
	assert(behind.reason == "目标位于身后")

	var blocked := PerceptionRules.evaluate_sight(
		Vector3(0, 0, 0),
		Vector3(0, 0, -1),
		Vector3(0, 0, -4),
		7.0,
		80.0,
		true,
	)
	assert(blocked.seen == false)
	assert(blocked.reason == "视线被遮挡")
	print("Godot perception-rule tests passed.")
	quit()
