from dataclasses import dataclass
from enum import StrEnum, auto


class Action(StrEnum):
    INSPECT_SCALE = auto()
    INVITE_WITNESS = auto()
    ASK_FOR_WEIGHT = auto()
    EXPOSE_MAGNET = auto()
    DEMAND_REFUND = auto()
    PARK_FOR_EXIT = auto()
    BLOCK_HELPER_PATH = auto()
    CONFRONT_WITHOUT_PROOF = auto()
    PUSH_AND_ESCAPE = auto()
    BRING_KNIFE = auto()
    ATTACK_FIRST = auto()


@dataclass(frozen=True)
class EventResult:
    outcome: str
    violence_started: bool
    street_story: str
    police_story: str
    proven_facts: frozenset[str] = frozenset()
    witness_knowledge: frozenset[str] = frozenset()


def play_scenario(actions: list[Action]) -> EventResult:
    action_set = set(actions)
    if {Action.BRING_KNIFE, Action.ATTACK_FIRST} <= action_set:
        return EventResult(
            outcome="violent_dominance",
            violence_started=True,
            street_story="外来人带刀砸摊，摊主成了受害者。",
            police_story="嫌疑人预先携带刀具并首先攻击。",
        )

    controlled_escape = {
        Action.PARK_FOR_EXIT,
        Action.BLOCK_HELPER_PATH,
        Action.CONFRONT_WITHOUT_PROOF,
        Action.PUSH_AND_ESCAPE,
    } <= action_set
    if controlled_escape:
        return EventResult(
            outcome="controlled_escape",
            violence_started=True,
            street_story="摊主先围人，双方推搡后顾客骑车离开。",
            police_story="买卖纠纷引发推搡，无人报告持械。",
        )

    public_proof = (
        Action.INSPECT_SCALE in actions
        and Action.INVITE_WITNESS in actions
        and Action.ASK_FOR_WEIGHT in actions
        and Action.EXPOSE_MAGNET in actions
    )
    if public_proof and Action.DEMAND_REFUND in actions:
        return EventResult(
            outcome="concession",
            violence_started=False,
            street_story="摊主在邻铺见证下被揭穿使用磁铁增重，退钱并收摊。",
            police_story="交易纠纷中发现作弊秤具，双方未发生肢体冲突。",
            proven_facts=frozenset({"scale_magnet", "false_weight"}),
            witness_knowledge=frozenset({"scale_magnet", "false_weight"}),
        )

    private_accusation = {
        Action.INSPECT_SCALE,
        Action.ASK_FOR_WEIGHT,
        Action.EXPOSE_MAGNET,
        Action.DEMAND_REFUND,
    } <= action_set
    if private_accusation:
        return EventResult(
            outcome="intimidated_exit",
            violence_started=False,
            street_story="有人指着秤说有问题，随后被摊主一伙赶走。",
            police_story="未接到需要处理的事件。",
        )

    return EventResult(
        outcome="unresolved",
        violence_started=False,
        street_story="一场没有说清的买卖争执。",
        police_story="未接到需要处理的事件。",
    )
