extends SceneTree

const HearingRules = preload("res://scripts/hearing_rules.gd")


func _initialize() -> void:
	var clear := HearingRules.evaluate_noise(
		Vector3.ZERO,
		Vector3(3, 0, 0),
		1.0,
		false,
	)
	assert(clear.heard == true)
	assert(clear.reason == "声音清晰可闻")

	var muffled := HearingRules.evaluate_noise(
		Vector3.ZERO,
		Vector3(3, 0, 0),
		1.0,
		true,
	)
	assert(muffled.heard == false)
	assert(muffled.reason == "声音被障碍削弱")

	var loud := HearingRules.evaluate_noise(
		Vector3.ZERO,
		Vector3(3, 0, 0),
		2.0,
		true,
	)
	assert(loud.heard == true)
	assert(loud.reason == "声音穿过障碍仍可听见")
	print("Godot hearing-rule tests passed.")
	quit()
