from yijinbaliang.event_engine import Action, play_scenario


ACTION_LABELS = {
    Action.INSPECT_SCALE: "趁摊主不注意观察秤盘",
    Action.INVITE_WITNESS: "请邻铺老板过来帮忙看秤",
    Action.ASK_FOR_WEIGHT: "让摊主公开报重量",
    Action.EXPOSE_MAGNET: "掀开秤盘指出磁铁",
    Action.DEMAND_REFUND: "要求退钱并承认作弊",
    Action.PARK_FOR_EXIT: "先把摩托掉头朝向巷口",
    Action.BLOCK_HELPER_PATH: "移动高脚凳挡住同伙通路",
    Action.CONFRONT_WITHOUT_PROOF: "没有公开证据便直接质问",
    Action.PUSH_AND_ESCAPE: "被围后推开对方并撤离",
    Action.BRING_KNIFE: "预先携带刀具",
    Action.ATTACK_FIRST: "首先攻击摊主",
}


def main() -> None:
    actions = list(ACTION_LABELS)
    print("《一斤八两》Phase 2 规则原型")
    print("依次输入行动编号；直接回车结束并结算。\n")
    for index, action in enumerate(actions, start=1):
        print(f"{index:>2}. {ACTION_LABELS[action]}")

    selected: list[Action] = []
    while True:
        value = input("\n行动> ").strip()
        if not value:
            break
        try:
            action = actions[int(value) - 1]
        except (ValueError, IndexError):
            print("请输入列表中的编号。")
            continue
        selected.append(action)
        print(f"已选择：{ACTION_LABELS[action]}")

    result = play_scenario(selected)
    print(f"\n结果：{result.outcome}")
    print(f"发生肢体冲突：{'是' if result.violence_started else '否'}")
    print(f"已证明事实：{', '.join(sorted(result.proven_facts)) or '无'}")
    print(f"街坊版本：{result.street_story}")
    print(f"警方版本：{result.police_story}")


if __name__ == "__main__":
    main()
