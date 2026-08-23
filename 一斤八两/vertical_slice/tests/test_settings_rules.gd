extends SceneTree

const SettingsRules = preload("res://scripts/settings_rules.gd")


func _initialize() -> void:
	var defaults := SettingsRules.normalize({})
	assert(defaults.master_volume == 0.8)
	assert(defaults.text_scale == 1.0)
	assert(defaults.reduce_motion == false)

	var clamped := SettingsRules.normalize({
		"master_volume": 2.0,
		"text_scale": 0.2,
		"reduce_motion": true,
	})
	assert(clamped.master_volume == 1.0)
	assert(clamped.text_scale == 0.8)
	assert(clamped.reduce_motion == true)
	print("Godot settings-rule tests passed.")
	quit()
