class_name SettingsRules
extends RefCounted


static func normalize(values: Dictionary) -> Dictionary:
	return {
		"master_volume": clampf(float(values.get("master_volume", 0.8)), 0.0, 1.0),
		"text_scale": clampf(float(values.get("text_scale", 1.0)), 0.8, 1.4),
		"reduce_motion": bool(values.get("reduce_motion", false)),
	}
