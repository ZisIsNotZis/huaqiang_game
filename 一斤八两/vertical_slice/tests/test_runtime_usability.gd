extends SceneTree

const EventState = preload("res://scripts/event_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var start: Vector3 = scene.player.position
	Input.action_press("move_forward")
	scene._physics_process(0.1)
	Input.action_release("move_forward")
	assert(scene.player.position.z > start.z, "Forward must move toward the top of the camera view.")

	var left_key := InputEventKey.new()
	left_key.keycode = KEY_LEFT
	assert(
		InputMap.event_is_action(left_key, "move_left"),
		"Left arrow mapping missing: %s / %s" % [KEY_LEFT, InputMap.action_get_events("move_left")],
	)
	var right_key := InputEventKey.new()
	right_key.keycode = KEY_RIGHT
	assert(InputMap.event_is_action(right_key, "move_right"))

	var old_yaw: float = scene.camera_yaw
	var old_pitch: float = scene.camera_pitch
	scene._rotate_camera(Vector2(40, -20))
	assert(scene.camera_yaw > old_yaw)
	assert(scene.camera_pitch != old_pitch)

	scene.player.position = Vector3(-8.4, 0.9, 2.7)
	scene._render_nearby_actions()
	assert(scene.last_nearby_actions == [EventState.Action.TALK_SISTER])
	scene._on_action(EventState.Action.TALK_SISTER)
	await process_frame
	assert(scene.last_nearby_actions.is_empty(), "A completed interaction must not leave a stale action.")
	assert(scene.nearby_hint.text == "")
	scene.player.position = Vector3(10.0, 0.9, -6.0)
	scene._render_nearby_actions()
	await process_frame
	assert(scene.last_nearby_actions.is_empty())
	assert(scene.nearby_hint.text == "")
	assert(scene.action_list.get_child_count() == 1)
	assert(scene.action_list.get_child(0).disabled)

	assert(scene.log_label.scroll_following, "The on-site log must follow newly appended content.")
	assert(scene.log_label.size_flags_vertical == Control.SIZE_EXPAND_FILL)

	var labels: Array[Node] = scene.find_children("*", "Label3D", true, false)
	assert(not labels.is_empty())
	for label in labels:
		assert(label.billboard != BaseMaterial3D.BILLBOARD_DISABLED)
		assert(label.font_size >= 32)

	print("Godot runtime usability tests passed.")
	quit()
