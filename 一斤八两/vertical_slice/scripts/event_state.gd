class_name EventState
extends RefCounted

const ConflictRules = preload("res://scripts/conflict_rules.gd")

enum Action {
	TALK_SISTER,
	REVIEW_PLAN,
	INSPECT_SCALE,
	INVITE_WITNESS,
	CHOOSE_MELON,
	ASK_GUARANTEE,
	ASK_FOR_WEIGHT,
	EXPOSE_MAGNET,
	CUT_MELON,
	DEMAND_REFUND,
	PARK_FOR_EXIT,
	BLOCK_HELPER_PATH,
	ACCUSE_EARLY,
	PUSH_AND_ESCAPE,
	DESPERATE_ESCAPE,
}


static func create_game(skip_intro := false) -> Dictionary:
	var initial_actions: Array = [
		Action.INSPECT_SCALE,
		Action.INVITE_WITNESS,
		Action.PARK_FOR_EXIT,
		Action.BLOCK_HELPER_PATH,
		Action.ACCUSE_EARLY,
	] if skip_intro else [Action.TALK_SISTER]
	return {
		"phase": "observe" if skip_intro else "arrival",
		"turn": 0,
		"short_mode": skip_intro,
		"facts": [],
		"witness_present": false,
		"witness_knowledge": [],
		"exit_prepared": false,
		"helper_blocked": false,
		"merchant_alert": 0,
		"merchant_support": 3,
		"available_actions": initial_actions,
		"log": [
			"你走进街市。摊主和两名帮手守着瓜摊。"
			if skip_intro
			else "下午四点，修车铺快打烊了。妹妹带着一只发白的生瓜回来。"
		],
		"result": {},
		"player_condition": "healthy",
		"epilogue_hook": "",
	}


static func perform_action(game: Dictionary, action: Action, context := {}) -> Dictionary:
	assert(action in game.available_actions, "Action is not currently available.")
	var next := game.duplicate(true)
	next.turn += 1
	var text := ""
	var observed: bool = context.get("observed", true)
	var heard: bool = context.get("heard", false)

	match action:
		Action.TALK_SISTER:
			next.phase = "prepare"
			_add_unique(next.facts, "sister_was_cheated")
			text = "妹妹说摊主少称了四斤，回去理论时还被两个帮手堵住。"
		Action.REVIEW_PLAN:
			next.phase = "observe"
			text = "你决定先确认事实，再决定是否公开对质。街市里的每双眼睛都可能改变结果。"
		Action.INSPECT_SCALE:
			_add_unique(next.facts, "scale_suspicious")
			if observed:
				next.merchant_alert += 1
			text = "你注意到秤盘回落得不自然。%s" % (
				"摊主开始留意你。" if observed else "摊主的视线被瓜摊挡住。"
			)
		Action.INVITE_WITNESS:
			next.witness_present = true
			text = "邻铺修表师傅走到摊前，摊主的两个帮手不再插话。"
		Action.CHOOSE_MELON:
			_add_unique(next.facts, "melon_selected")
			text = "你让摊主亲手挑一只瓜，避免他事后否认。"
		Action.ASK_GUARANTEE:
			_add_unique(next.facts, "public_guarantee")
			if next.witness_present:
				_add_unique(next.witness_knowledge, "public_guarantee")
			text = "摊主当众保证瓜熟，旁边的人都听见了。"
		Action.PARK_FOR_EXIT:
			next.exit_prepared = true
			text = "你把摩托掉头朝向巷口，钥匙留在锁孔里。"
		Action.BLOCK_HELPER_PATH:
			next.helper_blocked = true
			if observed or heard:
				next.merchant_alert += 1
			var reaction := "摊主看见了这个动作。" if observed else (
				"摊主听见了木凳摩擦地面。" if heard else "没人注意到这个动作。"
			)
			text = "你挪开高脚凳，狭窄通道只够一个人通过。%s" % reaction
		Action.ASK_FOR_WEIGHT:
			_add_unique(next.facts, "false_weight")
			if next.witness_present:
				_add_unique(next.witness_knowledge, "false_weight")
			text = "摊主公开报出十二斤。秤杆位置和瓜的大小明显对不上。"
		Action.EXPOSE_MAGNET:
			_add_unique(next.facts, "scale_magnet")
			if next.witness_present:
				_add_unique(next.witness_knowledge, "scale_magnet")
			next.merchant_support = 1 if next.witness_present else 3
			next.phase = "pressure" if next.witness_present else "conflict"
			text = "磁铁暴露在所有人眼前。帮手移开了视线。" if next.witness_present else "你掀出磁铁，但没人愿意替你作证。帮手围了上来。"
		Action.CUT_MELON:
			_add_unique(next.facts, "melon_unripe")
			if next.witness_present:
				_add_unique(next.witness_knowledge, "melon_unripe")
			next.merchant_support = 0 if next.witness_present else next.merchant_support
			next.phase = "pressure" if next.witness_present else "conflict"
			text = "瓜瓤发白。摊主刚才的保证和眼前事实同时被所有人记住。"
		Action.ACCUSE_EARLY:
			next.phase = "conflict"
			next.merchant_alert = 3
			text = "你没有拿出证据便直接指控。摊主示意帮手围住出口。"
		Action.DEMAND_REFUND:
			next.phase = "resolved"
			next.result = {
				"outcome": "concession",
				"violence_started": false,
				"street_story": "摊主在邻铺见证下被揭穿使用磁铁增重，退钱并收摊。",
				"police_story": "交易纠纷中发现作弊秤具，双方未发生肢体冲突。",
			}
			next.epilogue_hook = "修表师傅悄悄告诉你：城西四号磅房也在用类似手法。"
			text = "摊主失去帮手支持，只能退钱并暂时收摊。"
		Action.PUSH_AND_ESCAPE:
			var escape := ConflictRules.resolve_escape(
				next.exit_prepared,
				next.helper_blocked,
				next.merchant_support,
			)
			next.phase = "resolved"
			next.result = {
				"outcome": escape.outcome,
				"violence_started": true,
				"injury": escape.injury,
				"street_story": "摊主先围人，双方推搡后顾客骑车离开。",
				"police_story": "买卖纠纷引发推搡，无人报告持械。",
			}
			next.player_condition = escape.injury
			next.epilogue_hook = "当晚有人到修车铺门口盯梢，显然这件事没有结束。"
			text = "你推开唯一能靠近的人，跨上已经掉头的摩托离开。"
		Action.DESPERATE_ESCAPE:
			var escape := ConflictRules.resolve_escape(
				next.exit_prepared,
				next.helper_blocked,
				next.merchant_support,
			)
			next.phase = "resolved"
			next.player_condition = escape.injury
			next.result = {
				"outcome": escape.outcome,
				"violence_started": true,
				"injury": escape.injury,
				"street_story": "顾客先挑起争执，被三人围住后负伤逃离。",
				"police_story": "交易纠纷升级为多人斗殴，一人受伤离场。",
			}
			next.epilogue_hook = "伤势让你行动变慢，而摊主一伙已经开始打听你的住处。"
			text = "你没有退路，只能撞开人群。肋侧的剧痛会延续到下一章。"

	next.log.append(text)
	next.available_actions = _next_actions(next)
	return next


static func _next_actions(game: Dictionary) -> Array:
	if game.phase == "resolved":
		return []
	if game.phase == "prepare":
		return [Action.REVIEW_PLAN]
	if game.phase == "arrival":
		return [Action.TALK_SISTER]
	if (
		"scale_magnet" in game.facts
		and "false_weight" in game.facts
		and "scale_magnet" in game.witness_knowledge
		and (game.short_mode or "melon_unripe" in game.facts)
	):
		return [Action.DEMAND_REFUND]
	if game.phase == "conflict":
		return [Action.PUSH_AND_ESCAPE] if game.exit_prepared and game.helper_blocked else [Action.DESPERATE_ESCAPE]

	var actions: Array = [
		Action.INSPECT_SCALE,
		Action.INVITE_WITNESS,
		Action.PARK_FOR_EXIT,
		Action.BLOCK_HELPER_PATH,
		Action.ACCUSE_EARLY,
	]
	if "melon_selected" not in game.facts:
		actions.append(Action.CHOOSE_MELON)
	if "melon_selected" in game.facts and "public_guarantee" not in game.facts:
		actions.append(Action.ASK_GUARANTEE)
	if "scale_suspicious" in game.facts:
		actions.append(Action.ASK_FOR_WEIGHT)
	if "false_weight" in game.facts:
		actions.append(Action.EXPOSE_MAGNET)
	if (
		not game.short_mode
		and "public_guarantee" in game.facts
		and "scale_magnet" in game.facts
		and "melon_unripe" not in game.facts
	):
		actions.append(Action.CUT_MELON)
	return actions


static func _add_unique(values: Array, value: String) -> void:
	if value not in values:
		values.append(value)
