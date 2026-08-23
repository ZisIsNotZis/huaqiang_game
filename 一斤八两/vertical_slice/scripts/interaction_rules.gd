class_name InteractionRules
extends RefCounted


static func available_nearby_actions(
	available_actions: Array,
	player_position: Vector3,
	action_positions: Dictionary,
	max_distance: float,
) -> Array:
	var nearby: Array = []
	for action in available_actions:
		if action not in action_positions:
			continue
		var target: Vector3 = action_positions[action]
		var flat_player := Vector3(player_position.x, 0.0, player_position.z)
		var flat_target := Vector3(target.x, 0.0, target.z)
		if flat_player.distance_to(flat_target) <= max_distance:
			nearby.append(action)
	return nearby


static func nearest_available_action(
	available_actions: Array,
	player_position: Vector3,
	action_positions: Dictionary,
	max_distance: float,
) -> int:
	var nearest_action := -1
	var nearest_distance := INF
	var flat_player := Vector3(player_position.x, 0.0, player_position.z)
	for action in available_actions:
		if action not in action_positions:
			continue
		var target: Vector3 = action_positions[action]
		var distance := flat_player.distance_to(Vector3(target.x, 0.0, target.z))
		if distance <= max_distance and distance < nearest_distance:
			nearest_action = action
			nearest_distance = distance
	return nearest_action
