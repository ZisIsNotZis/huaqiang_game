extends Node3D

const EventState = preload("res://scripts/event_state.gd")
const InteractionRules = preload("res://scripts/interaction_rules.gd")
const PerceptionRules = preload("res://scripts/perception_rules.gd")
const HearingRules = preload("res://scripts/hearing_rules.gd")
const SettingsRules = preload("res://scripts/settings_rules.gd")
const AudioRules = preload("res://scripts/audio_rules.gd")
const SaveRules = preload("res://scripts/save_rules.gd")

const AUDIO_SAMPLE_RATE := 22050.0
const CAMERA_DISTANCE := 9.5
const CAMERA_MOUSE_SENSITIVITY := 0.003

const ACTION_LABELS := {
	EventState.Action.TALK_SISTER: "听妹妹讲清经过",
	EventState.Action.REVIEW_PLAN: "检查摩托并决定行动原则",
	EventState.Action.INSPECT_SCALE: "观察秤盘",
	EventState.Action.INVITE_WITNESS: "请修表师傅作证",
	EventState.Action.CHOOSE_MELON: "让摊主亲手挑瓜",
	EventState.Action.ASK_GUARANTEE: "让摊主公开保证瓜熟",
	EventState.Action.ASK_FOR_WEIGHT: "让摊主公开报重量",
	EventState.Action.EXPOSE_MAGNET: "揭露秤盘下的磁铁",
	EventState.Action.CUT_MELON: "当众切瓜验证",
	EventState.Action.DEMAND_REFUND: "要求退钱并收摊",
	EventState.Action.PARK_FOR_EXIT: "把摩托掉头朝向巷口",
	EventState.Action.BLOCK_HELPER_PATH: "移动木凳卡住通道",
	EventState.Action.ACCUSE_EARLY: "直接指控摊主作弊",
	EventState.Action.PUSH_AND_ESCAPE: "推开阻挡并撤离",
	EventState.Action.DESPERATE_ESCAPE: "强行撞开人群逃走",
}

const INJURY_LABELS := {
	"none": "无",
	"minor": "轻伤",
	"severe": "重伤",
}

var game := EventState.create_game()
var player: CharacterBody3D
var merchant: Node3D
var witness: Node3D
var helper_b: Node3D
var stool: Node3D
var motorcycle: Node3D
var sister: Node3D
var scale_object: Node3D
var shop_object: Node3D
var action_list: VBoxContainer
var log_label: RichTextLabel
var phase_label: Label
var alert_label: Label
var support_label: Label
var result_panel: PanelContainer
var result_label: RichTextLabel
var camera: Camera3D
var capture_mode := false
var highlight_capture := false
var nearby_hint: Label
var conflict_overlay: ColorRect
var last_nearby_actions: Array = []
var perception_label: Label
var hearing_label: Label
var pause_label: Label
var paused := false
var current_sight := {"seen": false, "reason": "尚未评估"}
var action_targets := {}
var highlighted_target: Node3D
var settings := SettingsRules.normalize({})
var settings_panel: PanelContainer
var side_panel: PanelContainer
var ambient_playback: AudioStreamGeneratorPlayback
var cue_playback: AudioStreamGeneratorPlayback
var ambient_phase := 0.0
var cue_phase := 0.0
var cue_frequency := 0.0
var cue_gain := 0.0
var cue_samples_remaining := 0
var camera_yaw := 0.0
var camera_pitch := 0.66

var action_positions := {
	EventState.Action.TALK_SISTER: Vector3(-8.4, 0.0, 2.7),
	EventState.Action.REVIEW_PLAN: Vector3(-8.2, 0.0, -4.8),
	EventState.Action.INSPECT_SCALE: Vector3(-1.4, 0.0, 0.7),
	EventState.Action.INVITE_WITNESS: Vector3(7.4, 0.0, 3.0),
	EventState.Action.CHOOSE_MELON: Vector3(-1.0, 0.0, 1.2),
	EventState.Action.ASK_GUARANTEE: Vector3(-1.5, 0.0, 1.8),
	EventState.Action.ASK_FOR_WEIGHT: Vector3(-1.5, 0.0, 1.6),
	EventState.Action.EXPOSE_MAGNET: Vector3(-1.4, 0.0, 0.7),
	EventState.Action.CUT_MELON: Vector3(-1.4, 0.0, 0.7),
	EventState.Action.DEMAND_REFUND: Vector3(-1.5, 0.0, 1.8),
	EventState.Action.PARK_FOR_EXIT: Vector3(-8.2, 0.0, -4.8),
	EventState.Action.BLOCK_HELPER_PATH: Vector3(4.2, 0.0, 0.5),
	EventState.Action.ACCUSE_EARLY: Vector3(-1.5, 0.0, 1.8),
	EventState.Action.PUSH_AND_ESCAPE: Vector3(-1.5, 0.0, 1.8),
	EventState.Action.DESPERATE_ESCAPE: Vector3(-1.5, 0.0, 1.8),
}

var action_loudness := {
	EventState.Action.TALK_SISTER: 0.7,
	EventState.Action.REVIEW_PLAN: 0.2,
	EventState.Action.INSPECT_SCALE: 0.25,
	EventState.Action.INVITE_WITNESS: 0.8,
	EventState.Action.CHOOSE_MELON: 0.8,
	EventState.Action.ASK_GUARANTEE: 1.2,
	EventState.Action.ASK_FOR_WEIGHT: 1.0,
	EventState.Action.EXPOSE_MAGNET: 1.3,
	EventState.Action.CUT_MELON: 1.8,
	EventState.Action.DEMAND_REFUND: 1.1,
	EventState.Action.PARK_FOR_EXIT: 1.2,
	EventState.Action.BLOCK_HELPER_PATH: 2.0,
	EventState.Action.ACCUSE_EARLY: 1.4,
	EventState.Action.PUSH_AND_ESCAPE: 2.2,
	EventState.Action.DESPERATE_ESCAPE: 2.6,
}


func _ready() -> void:
	highlight_capture = "--capture-highlight" in OS.get_cmdline_user_args()
	capture_mode = (
		"--capture" in OS.get_cmdline_user_args()
		or "--capture-resolved" in OS.get_cmdline_user_args()
		or "--capture-injured" in OS.get_cmdline_user_args()
		or "--capture-settings" in OS.get_cmdline_user_args()
		or highlight_capture
	)
	_load_settings_data()
	_build_audio()
	_build_world()
	_build_ui()
	if not capture_mode:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if highlight_capture:
		game = EventState.create_game(true)
		player.position = Vector3(-1.4, 0.9, -0.9)
	if "--capture-resolved" in OS.get_cmdline_user_args():
		for action in [
			EventState.Action.TALK_SISTER,
			EventState.Action.REVIEW_PLAN,
			EventState.Action.CHOOSE_MELON,
			EventState.Action.ASK_GUARANTEE,
			EventState.Action.INSPECT_SCALE,
			EventState.Action.INVITE_WITNESS,
			EventState.Action.ASK_FOR_WEIGHT,
			EventState.Action.EXPOSE_MAGNET,
			EventState.Action.CUT_MELON,
			EventState.Action.DEMAND_REFUND,
		]:
			game = EventState.perform_action(game, action)
	elif "--capture-injured" in OS.get_cmdline_user_args():
		game = EventState.create_game(true)
		game = EventState.perform_action(game, EventState.Action.ACCUSE_EARLY)
		game = EventState.perform_action(game, EventState.Action.DESPERATE_ESCAPE)
	_render_state()
	if "--capture-settings" in OS.get_cmdline_user_args():
		_toggle_settings()
	if capture_mode:
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().create_timer(0.4).timeout
		var image := get_viewport().get_texture().get_image()
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://screenshots"))
		var filename := "vertical_slice.png"
		if "--capture-resolved" in OS.get_cmdline_user_args():
			filename = "resolved.png"
		elif "--capture-injured" in OS.get_cmdline_user_args():
			filename = "injured.png"
		elif highlight_capture:
			filename = "highlight.png"
		elif "--capture-settings" in OS.get_cmdline_user_args():
			filename = "settings.png"
		image.save_png("res://screenshots/%s" % filename)
		get_tree().quit()


func _process(_delta: float) -> void:
	_fill_ambient_audio()
	_fill_cue_audio()


func _physics_process(delta: float) -> void:
	if paused:
		return
	if game.phase != "resolved":
		var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var camera_forward := -camera.global_basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()
		var camera_right := camera.global_basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()
		var direction := camera_right * input.x + camera_forward * -input.y
		player.velocity = direction.normalized() * 5.0
		player.move_and_slide()
		player.position.x = clampf(player.position.x, -11.0, 11.0)
		player.position.z = clampf(player.position.z, -6.5, 7.0)
		if direction.length() > 0.1:
			player.rotation.y = lerp_angle(player.rotation.y, atan2(direction.x, direction.z), delta * 10.0)
	if not capture_mode or highlight_capture:
		var horizontal_distance := cos(camera_pitch) * CAMERA_DISTANCE
		var desired := player.position + Vector3(
			sin(camera_yaw) * horizontal_distance,
			sin(camera_pitch) * CAMERA_DISTANCE,
			-cos(camera_yaw) * horizontal_distance,
		)
		camera.position = camera.position.lerp(desired, minf(delta * 5.0, 1.0))
		camera.look_at(player.position + Vector3(0, 0.8, 0))
	_render_nearby_actions()
	_update_perception()


func _build_audio() -> void:
	var ambient_stream := AudioStreamGenerator.new()
	ambient_stream.mix_rate = AUDIO_SAMPLE_RATE
	ambient_stream.buffer_length = 0.25
	var ambient_player := AudioStreamPlayer.new()
	ambient_player.stream = ambient_stream
	ambient_player.volume_db = -24.0
	add_child(ambient_player)
	ambient_player.play()
	ambient_playback = ambient_player.get_stream_playback()

	var cue_stream := AudioStreamGenerator.new()
	cue_stream.mix_rate = AUDIO_SAMPLE_RATE
	cue_stream.buffer_length = 0.25
	var cue_player := AudioStreamPlayer.new()
	cue_player.stream = cue_stream
	add_child(cue_player)
	cue_player.play()
	cue_playback = cue_player.get_stream_playback()


func _fill_ambient_audio() -> void:
	if ambient_playback == null:
		return
	var frames := ambient_playback.get_frames_available()
	for index in frames:
		var street_hum := sin(ambient_phase) * 0.035
		var distant_motor := sin(ambient_phase * 1.91) * 0.018
		var pulse := sin(ambient_phase * 0.071) * 0.012
		var sample := street_hum + distant_motor + pulse
		ambient_playback.push_frame(Vector2(sample, sample))
		ambient_phase = fmod(ambient_phase + TAU * 54.0 / AUDIO_SAMPLE_RATE, TAU)


func _fill_cue_audio() -> void:
	if cue_playback == null:
		return
	var frames := cue_playback.get_frames_available()
	for index in frames:
		var sample := 0.0
		if cue_samples_remaining > 0:
			var envelope := minf(float(cue_samples_remaining) / (AUDIO_SAMPLE_RATE * 0.025), 1.0)
			sample = sin(cue_phase) * cue_gain * envelope
			cue_phase = fmod(cue_phase + TAU * cue_frequency / AUDIO_SAMPLE_RATE, TAU)
			cue_samples_remaining -= 1
		cue_playback.push_frame(Vector2(sample, sample))


func _play_action_cue(action: EventState.Action) -> void:
	var profile := AudioRules.profile_for_action(action)
	cue_frequency = profile.frequency
	cue_gain = profile.gain
	cue_samples_remaining = roundi(profile.duration * AUDIO_SAMPLE_RATE)
	cue_phase = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not paused:
		_rotate_camera(event.relative)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		paused = not paused
		pause_label.visible = paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	elif not paused and event.is_action_pressed("interact") and last_nearby_actions.size() == 1:
		_on_action(last_nearby_actions[0])
		get_viewport().set_input_as_handled()


func _rotate_camera(relative_motion: Vector2) -> void:
	camera_yaw += relative_motion.x * CAMERA_MOUSE_SENSITIVITY
	camera_pitch = clampf(
		camera_pitch - relative_motion.y * CAMERA_MOUSE_SENSITIVITY,
		0.2,
		1.15,
	)


func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("151812")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("829078")
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_color = Color("e8d39b")
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	add_child(sun)

	_add_box("Street", Vector3(24, 0.2, 5), Vector3(0, -0.1, -5.5), Color("4a4b43"))
	_add_box("Pavement", Vector3(24, 0.35, 9), Vector3(0, 0.05, 1.5), Color("777362"))
	_add_box("BackWall", Vector3(24, 5, 0.35), Vector3(0, 2.5, 6), Color("9b927c"))
	shop_object = _add_box("Shop", Vector3(5, 4, 3), Vector3(8.3, 2, 4.3), Color("485044"))
	_add_label("修表铺", Vector3(8.3, 4.2, 2.7), Color("d4cfb7"), 38)

	_add_box("Stall", Vector3(10, 1.15, 2.4), Vector3(-1.2, 0.75, 1.8), Color("72563a"))
	for x in [-4.9, -3.8, -2.7, -1.6, -0.5, 0.6, 1.7, 2.8]:
		_add_sphere("Melon", 0.48, Vector3(x, 1.65, 1.55), Color("365b38"))
	scale_object = _add_box("Scale", Vector3(1.2, 0.35, 0.9), Vector3(-1.4, 1.58, 0.7), Color("767b68"))
	_add_label("秤", scale_object.position + Vector3(0, 0.55, 0), Color("efe9cc"), 26)

	_add_box("DryCleaner", Vector3(5.5, 4, 3), Vector3(-8.5, 2, 4.3), Color("5b493d"))
	_add_label("工农干洗", Vector3(-8.5, 4.2, 2.7), Color("d2c6aa"), 32)
	sister = _add_person("周岚", Vector3(-8.4, 0.9, 2.6), Color("7186a0"))
	_add_person("路人", Vector3(7.1, 0.9, -2.6), Color("7f7a69"))

	player = _add_person("周烈", Vector3(-1.6, 0.9, -1.8), Color("d7b754"), true)
	merchant = _add_person("摊主", Vector3(-1.5, 0.9, 3.5), Color("b9463b"))
	_add_person("帮手甲", Vector3(1.0, 0.9, 3.8), Color("a26552"))
	helper_b = _add_person("帮手乙", Vector3(4.1, 0.9, 3.2), Color("a26552"))
	witness = _add_person("修表师傅", Vector3(8.2, 0.9, 3.0), Color("559080"))
	witness.visible = false

	stool = _add_box("WoodStool", Vector3(1.1, 0.75, 1.1), Vector3(4.2, 0.45, 0.5), Color("493a2c"))
	_add_label("通道", Vector3(4.2, 0.4, -0.4), Color("d4cfb7"), 24)
	motorcycle = _add_box("Motorcycle", Vector3(2.1, 0.9, 0.8), Vector3(-8.2, 0.55, -4.8), Color("252824"))
	_add_label("摩托 / 撤离", motorcycle.position + Vector3(0, 0.85, 0), Color("e4dfc8"), 24)

	action_targets = {
		EventState.Action.TALK_SISTER: sister,
		EventState.Action.REVIEW_PLAN: motorcycle,
		EventState.Action.INSPECT_SCALE: scale_object,
		EventState.Action.INVITE_WITNESS: shop_object,
		EventState.Action.CHOOSE_MELON: scale_object,
		EventState.Action.ASK_GUARANTEE: merchant,
		EventState.Action.ASK_FOR_WEIGHT: merchant,
		EventState.Action.EXPOSE_MAGNET: scale_object,
		EventState.Action.CUT_MELON: scale_object,
		EventState.Action.DEMAND_REFUND: merchant,
		EventState.Action.PARK_FOR_EXIT: motorcycle,
		EventState.Action.BLOCK_HELPER_PATH: stool,
		EventState.Action.ACCUSE_EARLY: merchant,
		EventState.Action.PUSH_AND_ESCAPE: merchant,
		EventState.Action.DESPERATE_ESCAPE: merchant,
	}

	camera = Camera3D.new()
	camera.position = Vector3(-3.0, 15.5, -15.5)
	camera.fov = 54
	add_child(camera)
	camera.look_at(Vector3(-2.0, 0.8, 1.2))


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var title := Label.new()
	title.position = Vector2(28, 22)
	title.text = "一斤八两  /  第一章：一块磁铁"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("ecd47e"))
	canvas.add_child(title)

	var hint := Label.new()
	hint.position = Vector2(30, 60)
	hint.text = "方向键 / WASD 移动 · E 互动 · Esc 暂停"
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color("b9b7a8"))
	canvas.add_child(hint)

	nearby_hint = Label.new()
	nearby_hint.position = Vector2(30, 500)
	nearby_hint.size = Vector2(850, 44)
	nearby_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nearby_hint.add_theme_font_size_override("font_size", 19)
	nearby_hint.add_theme_color_override("font_color", Color("f0dc87"))
	nearby_hint.add_theme_color_override("font_outline_color", Color("171811"))
	nearby_hint.add_theme_constant_override("outline_size", 5)
	canvas.add_child(nearby_hint)

	side_panel = PanelContainer.new()
	side_panel.position = Vector2(930, 24)
	side_panel.size = Vector2(326, 650)
	canvas.add_child(side_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	side_panel.add_child(margin)
	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 9)
	margin.add_child(content)

	phase_label = _ui_label(content, "", 18, Color("e9d47f"))
	alert_label = _ui_label(content, "", 15, Color("d8d4c4"))
	support_label = _ui_label(content, "", 15, Color("d8d4c4"))
	_ui_label(content, "可执行行动", 15, Color("9da18e"))
	action_list = VBoxContainer.new()
	action_list.add_theme_constant_override("separation", 6)
	content.add_child(action_list)
	_ui_label(content, "现场记录", 15, Color("9da18e"))
	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(285, 210)
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_label.fit_content = false
	log_label.scroll_following = true
	log_label.bbcode_enabled = true
	log_label.add_theme_font_size_override("normal_font_size", 14)
	content.add_child(log_label)

	result_panel = PanelContainer.new()
	result_panel.position = Vector2(28, 564)
	result_panel.size = Vector2(870, 110)
	result_panel.visible = false
	canvas.add_child(result_panel)
	result_label = RichTextLabel.new()
	result_label.bbcode_enabled = true
	result_label.fit_content = true
	result_label.add_theme_font_size_override("normal_font_size", 16)
	result_panel.add_child(result_label)

	var restart := Button.new()
	restart.position = Vector2(1120, 676)
	restart.size = Vector2(136, 34)
	restart.text = "重开事件"
	restart.pressed.connect(_restart_event)
	canvas.add_child(restart)

	conflict_overlay = ColorRect.new()
	conflict_overlay.position = Vector2.ZERO
	conflict_overlay.size = Vector2(930, 720)
	conflict_overlay.color = Color(0.45, 0.03, 0.02, 0.0)
	conflict_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(conflict_overlay)

	perception_label = Label.new()
	perception_label.position = Vector2(30, 96)
	perception_label.add_theme_font_size_override("font_size", 15)
	perception_label.add_theme_color_override("font_color", Color("b8c4aa"))
	canvas.add_child(perception_label)

	hearing_label = Label.new()
	hearing_label.position = Vector2(30, 122)
	hearing_label.add_theme_font_size_override("font_size", 15)
	hearing_label.add_theme_color_override("font_color", Color("9aa793"))
	hearing_label.text = "摊主听觉：环境安静"
	canvas.add_child(hearing_label)

	pause_label = Label.new()
	pause_label.position = Vector2(0, 300)
	pause_label.size = Vector2(930, 80)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.text = "已暂停\n按 Esc 继续"
	pause_label.add_theme_font_size_override("font_size", 26)
	pause_label.add_theme_color_override("font_color", Color("f0d679"))
	pause_label.visible = false
	canvas.add_child(pause_label)

	var load_checkpoint := Button.new()
	load_checkpoint.position = Vector2(970, 676)
	load_checkpoint.size = Vector2(142, 34)
	load_checkpoint.text = "读取检查点"
	load_checkpoint.pressed.connect(_load_checkpoint)
	canvas.add_child(load_checkpoint)

	var settings_button := Button.new()
	settings_button.position = Vector2(824, 676)
	settings_button.size = Vector2(138, 34)
	settings_button.text = "设置"
	settings_button.pressed.connect(_toggle_settings)
	canvas.add_child(settings_button)

	settings_panel = PanelContainer.new()
	settings_panel.position = Vector2(360, 164)
	settings_panel.size = Vector2(520, 390)
	settings_panel.visible = false
	canvas.add_child(settings_panel)
	var settings_margin := MarginContainer.new()
	settings_margin.add_theme_constant_override("margin_left", 28)
	settings_margin.add_theme_constant_override("margin_right", 28)
	settings_margin.add_theme_constant_override("margin_top", 24)
	settings_margin.add_theme_constant_override("margin_bottom", 24)
	settings_panel.add_child(settings_margin)
	var settings_content := VBoxContainer.new()
	settings_content.add_theme_constant_override("separation", 14)
	settings_margin.add_child(settings_content)
	_ui_label(settings_content, "设置与无障碍", 24, Color("ead172"))
	_ui_label(settings_content, "主音量", 15, Color("d8d4c4"))
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = settings.master_volume
	volume.value_changed.connect(_on_volume_changed)
	settings_content.add_child(volume)
	_ui_label(settings_content, "文字缩放", 15, Color("d8d4c4"))
	var text_scale := OptionButton.new()
	text_scale.add_item("80%", 0)
	text_scale.add_item("100%", 1)
	text_scale.add_item("120%", 2)
	text_scale.add_item("140%", 3)
	text_scale.select(_text_scale_index(settings.text_scale))
	text_scale.item_selected.connect(_on_text_scale_selected)
	settings_content.add_child(text_scale)
	var reduce_motion := CheckBox.new()
	reduce_motion.text = "减少镜头与冲突运动"
	reduce_motion.button_pressed = settings.reduce_motion
	reduce_motion.toggled.connect(_on_reduce_motion_toggled)
	settings_content.add_child(reduce_motion)
	var close_settings := Button.new()
	close_settings.text = "关闭"
	close_settings.pressed.connect(_toggle_settings)
	settings_content.add_child(close_settings)
	_apply_settings()


func _render_state() -> void:
	phase_label.text = "阶段：%s" % game.phase
	alert_label.text = "摊主警觉：%d / 3" % game.merchant_alert
	support_label.text = "帮手支持：%d / 3" % game.merchant_support
	witness.visible = game.witness_present
	stool.position = Vector3(4.2, 0.45, 2.15) if game.helper_blocked else Vector3(4.2, 0.45, 0.5)
	helper_b.position = Vector3(5.7, 0.9, 3.3) if game.helper_blocked else Vector3(4.1, 0.9, 3.2)
	motorcycle.rotation.y = PI if game.exit_prepared else 0.0

	last_nearby_actions = [null]
	_render_nearby_actions()

	var lines: Array[String] = []
	for index in game.log.size():
		lines.append("%d. %s" % [index + 1, game.log[index]])
	log_label.text = "\n".join(lines)
	log_label.call_deferred("scroll_to_line", maxi(game.log.size() - 1, 0))

	result_panel.visible = not game.result.is_empty()
	if not game.result.is_empty():
		result_label.text = (
			"[color=#e8cf72][font_size=21]事件结束 · %s[/font_size][/color]\n"
			+ "[b]伤势：[/b]%s\n[b]街坊版本：[/b]%s\n[b]警方版本：[/b]%s\n[b]后续：[/b]%s"
		) % [
			game.result.outcome,
			INJURY_LABELS.get(game.result.get("injury", "none"), "未知"),
			game.result.street_story,
			game.result.police_story,
			game.epilogue_hook,
		]


func _render_nearby_actions() -> void:
	if action_list == null:
		return
	var nearby: Array = game.available_actions
	if not capture_mode or highlight_capture:
		var nearest := InteractionRules.nearest_available_action(
			game.available_actions,
			player.position,
			action_positions,
			2.4,
		)
		nearby = [] if nearest == -1 else [nearest]
	if nearby == last_nearby_actions:
		return
	last_nearby_actions = nearby.duplicate()
	_set_highlight(null)
	for child in action_list.get_children():
		child.queue_free()
	for action in nearby:
		var button := Button.new()
		button.text = ACTION_LABELS[action]
		button.custom_minimum_size = Vector2(285, 36)
		button.pressed.connect(_on_action.bind(action))
		action_list.add_child(button)
	if nearby.is_empty() and not game.available_actions.is_empty():
		var disabled := Button.new()
		disabled.text = "靠近现场物件或人物以行动"
		disabled.disabled = true
		action_list.add_child(disabled)
	nearby_hint.text = "" if (capture_mode and not highlight_capture) or nearby.is_empty() else "附近可互动：%s" % ACTION_LABELS[nearby[0]]
	if (not capture_mode or highlight_capture) and nearby.size() == 1:
		nearby_hint.text += "  [E]"
		_set_highlight(action_targets.get(nearby[0]))


func _on_action(action: EventState.Action) -> void:
	var nearest := InteractionRules.nearest_available_action(
		game.available_actions,
		player.position,
		action_positions,
		2.4,
	)
	if not capture_mode and nearest != action:
		_render_nearby_actions()
		return
	var previous_phase: String = game.phase
	var previous_alert: int = game.merchant_alert
	_play_action_cue(action)
	var hearing := HearingRules.evaluate_noise(
		merchant.position,
		player.position,
		action_loudness.get(action, 0.0),
		not current_sight.seen,
	)
	game = EventState.perform_action(
		game,
		action,
		{"observed": current_sight.seen, "heard": hearing.heard},
	)
	hearing_label.text = "摊主听觉：%s · %s" % [
		"听见行动" if hearing.heard else "没有听见",
		hearing.reason,
	]
	if game.merchant_alert > previous_alert and game.merchant_alert >= 2:
		_play_merchant_approach()
	_save_checkpoint()
	if previous_phase != "conflict" and game.phase == "conflict":
		_play_conflict_warning()
	if action == EventState.Action.PUSH_AND_ESCAPE:
		_play_escape()
	elif action == EventState.Action.DESPERATE_ESCAPE:
		_play_injured_escape()
	_render_state()


func _play_conflict_warning() -> void:
	if settings.reduce_motion:
		conflict_overlay.color.a = 0.18
		await get_tree().create_timer(0.18).timeout
		conflict_overlay.color.a = 0.0
		helper_b.position = Vector3(2.9, 0.9, 1.7)
		return
	var tween := create_tween()
	tween.tween_property(conflict_overlay, "color:a", 0.22, 0.16)
	tween.tween_property(conflict_overlay, "color:a", 0.0, 0.65)
	tween.parallel().tween_property(helper_b, "position", Vector3(2.9, 0.9, 1.7), 0.55)


func _play_escape() -> void:
	if settings.reduce_motion:
		player.position = motorcycle.position + Vector3(1.2, 0.35, 0)
		return
	var tween := create_tween()
	tween.tween_property(player, "position", motorcycle.position + Vector3(1.2, 0.35, 0), 0.8)


func _play_injured_escape() -> void:
	if settings.reduce_motion:
		player.rotation.z = deg_to_rad(24)
		player.position = motorcycle.position + Vector3(2.5, 0.35, 0.8)
		return
	var tween := create_tween()
	tween.tween_property(player, "rotation:z", deg_to_rad(24), 0.18)
	tween.tween_property(player, "position", motorcycle.position + Vector3(2.5, 0.35, 0.8), 1.35)


func _play_merchant_approach() -> void:
	if settings.reduce_motion:
		merchant.position = Vector3(-1.5, 0.9, 2.7)
		return
	var tween := create_tween()
	tween.tween_property(merchant, "position", Vector3(-1.5, 0.9, 2.7), 0.45)


func _restart_event() -> void:
	game = EventState.create_game()
	player.position = Vector3(-1.6, 0.9, -1.8)
	merchant.position = Vector3(-1.5, 0.9, 3.5)
	hearing_label.text = "摊主听觉：环境安静"
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://checkpoint.json"))
	_render_state()


func _load_checkpoint() -> void:
	if not FileAccess.file_exists("user://checkpoint.json"):
		nearby_hint.text = "没有可读取的检查点"
		return
	var file := FileAccess.open("user://checkpoint.json", FileAccess.READ)
	if file == null:
		push_error("Unable to read checkpoint.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	var decoded := SaveRules.decode(parsed)
	if not decoded.ok:
		push_error("Unable to load checkpoint: %s" % decoded.error)
		nearby_hint.text = "检查点损坏：%s" % decoded.error
		return
	game = decoded.game
	if decoded.migrated:
		_save_checkpoint()
	_render_state()


func _update_perception() -> void:
	var observer_forward := Vector3(0, 0, -1)
	var occluded := _is_sight_occluded()
	current_sight = PerceptionRules.evaluate_sight(
		merchant.position,
		observer_forward,
		player.position,
		7.0,
		90.0,
		occluded,
	)
	perception_label.text = "摊主观察：%s · %s" % [
		"看见你" if current_sight.seen else "未看见你",
		current_sight.reason,
	]
	perception_label.add_theme_color_override(
		"font_color",
		Color("d79879") if current_sight.seen else Color("93a18d"),
	)


func _is_sight_occluded() -> bool:
	if not is_inside_tree():
		return false
	var query := PhysicsRayQueryParameters3D.create(
		merchant.global_position + Vector3(0, 0.8, 0),
		player.global_position + Vector3(0, 0.7, 0),
	)
	query.exclude = [player.get_rid()]
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _save_checkpoint() -> void:
	var file := FileAccess.open("user://checkpoint.json", FileAccess.WRITE)
	if file == null:
		push_error("Unable to save checkpoint.")
		return
	file.store_string(JSON.stringify(SaveRules.encode(game)))


func _load_settings_data() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		return
	var file := FileAccess.open("user://settings.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		settings = SettingsRules.normalize(parsed)


func _save_settings() -> void:
	var file := FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file == null:
		push_error("Unable to save settings.")
		return
	file.store_string(JSON.stringify(settings))


func _apply_settings() -> void:
	var volume: float = settings.master_volume
	AudioServer.set_bus_mute(0, volume <= 0.001)
	if volume > 0.001:
		AudioServer.set_bus_volume_db(0, linear_to_db(volume))
	if side_panel != null:
		var theme := Theme.new()
		theme.default_font_size = roundi(16.0 * settings.text_scale)
		side_panel.theme = theme


func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	paused = settings_panel.visible
	pause_label.visible = false


func _on_volume_changed(value: float) -> void:
	settings.master_volume = value
	_apply_settings()
	_save_settings()


func _on_text_scale_selected(index: int) -> void:
	settings.text_scale = [0.8, 1.0, 1.2, 1.4][index]
	_apply_settings()
	_save_settings()


func _on_reduce_motion_toggled(enabled: bool) -> void:
	settings.reduce_motion = enabled
	_save_settings()


func _text_scale_index(value: float) -> int:
	var options := [0.8, 1.0, 1.2, 1.4]
	var nearest := 0
	var nearest_distance := INF
	for index in options.size():
		var distance: float = absf(options[index] - value)
		if distance < nearest_distance:
			nearest = index
			nearest_distance = distance
	return nearest


func _set_highlight(target: Node3D) -> void:
	if highlighted_target != null:
		_apply_highlight(highlighted_target, false)
	highlighted_target = target
	if highlighted_target != null:
		_apply_highlight(highlighted_target, true)


func _apply_highlight(target: Node3D, enabled: bool) -> void:
	var mesh_instance := target as MeshInstance3D
	if mesh_instance == null:
		for child in target.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	if mesh_instance == null:
		return
	var material := mesh_instance.mesh.material as StandardMaterial3D
	if material == null:
		return
	material.emission_enabled = enabled
	material.emission = Color("e8c85e")
	material.emission_energy_multiplier = 0.75 if enabled else 0.0


func _add_box(node_name: String, size: Vector3, position_value: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _material(color)
	mesh_instance.mesh = mesh
	mesh_instance.position = position_value
	add_child(mesh_instance)
	var static_body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	static_body.add_child(collision)
	mesh_instance.add_child(static_body)
	return mesh_instance


func _add_sphere(node_name: String, radius: float, position_value: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.material = _material(color)
	mesh_instance.mesh = mesh
	mesh_instance.position = position_value
	add_child(mesh_instance)
	return mesh_instance


func _add_person(label_text: String, position_value: Vector3, color: Color, controlled := false) -> Node3D:
	var root: Node3D = CharacterBody3D.new() if controlled else Node3D.new()
	root.name = label_text
	root.position = position_value
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.65
	capsule.material = _material(color)
	body.mesh = capsule
	root.add_child(body)
	if controlled:
		var collision := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = 0.42
		shape.height = 1.65
		collision.shape = shape
		root.add_child(collision)
	var label := Label3D.new()
	label.text = label_text
	label.position = Vector3(0, 1.25, 0)
	label.font_size = 42
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color("f1ecd9")
	label.outline_size = 7
	root.add_child(label)
	add_child(root)
	return root


func _add_label(text_value: String, position_value: Vector3, color: Color, size: int) -> Label3D:
	var label := Label3D.new()
	label.text = text_value
	label.position = position_value
	label.font_size = maxi(size, 34)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = color
	label.outline_size = 8
	add_child(label)
	return label


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material


func _ui_label(parent: Control, text_value: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label
