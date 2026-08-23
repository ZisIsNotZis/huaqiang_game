export const ACTIONS = Object.freeze({
  INSPECT_SCALE: "inspect_scale",
  INVITE_WITNESS: "invite_witness",
  ASK_FOR_WEIGHT: "ask_for_weight",
  EXPOSE_MAGNET: "expose_magnet",
  DEMAND_REFUND: "demand_refund",
  PARK_FOR_EXIT: "park_for_exit",
  BLOCK_HELPER_PATH: "block_helper_path",
  ACCUSE_EARLY: "accuse_early",
  PUSH_AND_ESCAPE: "push_and_escape",
});

const INITIAL_ACTIONS = [
  ACTIONS.INSPECT_SCALE,
  ACTIONS.INVITE_WITNESS,
  ACTIONS.PARK_FOR_EXIT,
  ACTIONS.BLOCK_HELPER_PATH,
  ACTIONS.ACCUSE_EARLY,
];

export function createGame() {
  return {
    phase: "observe",
    turn: 0,
    facts: [],
    witnessPresent: false,
    witnessKnowledge: [],
    exitPrepared: false,
    helperBlocked: false,
    npc: {
      merchant: { alert: 0, support: 3 },
    },
    availableActions: [...INITIAL_ACTIONS],
    log: ["你走进街市。摊主和两名帮手守着瓜摊。"],
    result: null,
  };
}

function appendUnique(values, value) {
  return values.includes(value) ? values : [...values, value];
}

function nextActions(game) {
  if (game.phase === "resolved") return [];
  if (
    game.facts.includes("scale_magnet") &&
    game.facts.includes("false_weight") &&
    game.witnessKnowledge.includes("scale_magnet")
  ) {
    return [ACTIONS.DEMAND_REFUND];
  }
  if (game.phase === "conflict") {
    return game.exitPrepared && game.helperBlocked ? [ACTIONS.PUSH_AND_ESCAPE] : [];
  }

  const actions = [...INITIAL_ACTIONS];
  if (game.facts.includes("scale_suspicious")) actions.push(ACTIONS.ASK_FOR_WEIGHT);
  if (game.facts.includes("false_weight")) actions.push(ACTIONS.EXPOSE_MAGNET);
  return actions.filter((action) => !game.log.some((entry) => entry.action === action));
}

export function performAction(game, action) {
  if (!game.availableActions.includes(action)) {
    throw new Error(`Action is not currently available: ${action}`);
  }

  const next = {
    ...game,
    turn: game.turn + 1,
    facts: [...game.facts],
    witnessKnowledge: [...game.witnessKnowledge],
    npc: { merchant: { ...game.npc.merchant } },
    log: [...game.log],
  };

  let text = "";
  if (action === ACTIONS.INSPECT_SCALE) {
    next.facts = appendUnique(next.facts, "scale_suspicious");
    next.npc.merchant.alert += 1;
    text = "你注意到秤盘回落得不自然。摊主开始留意你。";
  } else if (action === ACTIONS.INVITE_WITNESS) {
    next.witnessPresent = true;
    text = "邻铺修表师傅走到摊前，摊主的两个帮手不再插话。";
  } else if (action === ACTIONS.PARK_FOR_EXIT) {
    next.exitPrepared = true;
    text = "你把摩托掉头朝向巷口，钥匙留在锁孔里。";
  } else if (action === ACTIONS.BLOCK_HELPER_PATH) {
    next.helperBlocked = true;
    next.npc.merchant.alert += 1;
    text = "你挪开高脚凳，狭窄通道只够一个人通过。";
  } else if (action === ACTIONS.ASK_FOR_WEIGHT) {
    next.facts = appendUnique(next.facts, "false_weight");
    if (next.witnessPresent) {
      next.witnessKnowledge = appendUnique(next.witnessKnowledge, "false_weight");
    }
    text = "摊主公开报出十二斤。秤杆位置和瓜的大小明显对不上。";
  } else if (action === ACTIONS.EXPOSE_MAGNET) {
    next.facts = appendUnique(next.facts, "scale_magnet");
    if (next.witnessPresent) {
      next.witnessKnowledge = appendUnique(next.witnessKnowledge, "scale_magnet");
    }
    next.npc.merchant.support = next.witnessPresent ? 1 : 3;
    next.phase = next.witnessPresent ? "pressure" : "conflict";
    text = next.witnessPresent
      ? "磁铁暴露在所有人眼前。帮手移开了视线。"
      : "你掀出磁铁，但周围没人愿意替你作证。帮手围了上来。";
  } else if (action === ACTIONS.ACCUSE_EARLY) {
    next.phase = "conflict";
    next.npc.merchant.alert = 3;
    text = "你没有拿出证据便直接指控。摊主示意帮手围住出口。";
  } else if (action === ACTIONS.DEMAND_REFUND) {
    next.phase = "resolved";
    next.result = {
      outcome: "concession",
      violenceStarted: false,
      streetStory: "摊主在邻铺见证下被揭穿使用磁铁增重，退钱并收摊。",
      policeStory: "交易纠纷中发现作弊秤具，双方未发生肢体冲突。",
    };
    text = "摊主失去帮手支持，只能退钱并暂时收摊。";
  } else if (action === ACTIONS.PUSH_AND_ESCAPE) {
    next.phase = "resolved";
    next.result = {
      outcome: "controlled_escape",
      violenceStarted: true,
      streetStory: "摊主先围人，双方推搡后顾客骑车离开。",
      policeStory: "买卖纠纷引发推搡，无人报告持械。",
    };
    text = "你推开唯一能靠近的人，跨上已经掉头的摩托离开。";
  }

  next.log.push({ action, text });
  next.availableActions = nextActions(next);
  return next;
}
