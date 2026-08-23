class_name PerceptionRules
extends RefCounted


static func evaluate_sight(
	observer_position: Vector3,
	observer_forward: Vector3,
	target_position: Vector3,
	max_distance: float,
	field_of_view_degrees: float,
	occluded: bool,
) -> Dictionary:
	var to_target := target_position - observer_position
	var flat_target := Vector3(to_target.x, 0.0, to_target.z)
	if flat_target.length() > max_distance:
		return {"seen": false, "reason": "目标超出观察距离"}
	if flat_target.is_zero_approx():
		return {"seen": true, "reason": "目标位于身边"}

	var flat_forward := Vector3(observer_forward.x, 0.0, observer_forward.z).normalized()
	var direction := flat_target.normalized()
	var dot := flat_forward.dot(direction)
	if dot <= 0.0:
		return {"seen": false, "reason": "目标位于身后"}
	var half_angle := deg_to_rad(field_of_view_degrees * 0.5)
	if dot < cos(half_angle):
		return {"seen": false, "reason": "目标位于视野边缘之外"}
	if occluded:
		return {"seen": false, "reason": "视线被遮挡"}
	return {"seen": true, "reason": "目标位于视野内"}
