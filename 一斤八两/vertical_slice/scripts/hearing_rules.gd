class_name HearingRules
extends RefCounted


static func evaluate_noise(
	listener_position: Vector3,
	source_position: Vector3,
	loudness: float,
	occluded: bool,
) -> Dictionary:
	var distance := listener_position.distance_to(source_position)
	var effective_radius := maxf(loudness, 0.0) * 5.0
	if occluded:
		effective_radius *= 0.45
	if distance > effective_radius:
		return {
			"heard": false,
			"reason": "声音被障碍削弱" if occluded else "声音距离过远",
		}
	return {
		"heard": true,
		"reason": "声音穿过障碍仍可听见" if occluded else "声音清晰可闻",
	}
