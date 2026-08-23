import { ACTIONS, createGame, performAction } from "./event-state.js";

const LABELS = {
  [ACTIONS.INSPECT_SCALE]: "观察秤盘",
  [ACTIONS.INVITE_WITNESS]: "请邻铺师傅过来看秤",
  [ACTIONS.ASK_FOR_WEIGHT]: "让摊主公开报重量",
  [ACTIONS.EXPOSE_MAGNET]: "掀开秤盘揭露磁铁",
  [ACTIONS.DEMAND_REFUND]: "要求退钱并收摊",
  [ACTIONS.PARK_FOR_EXIT]: "把摩托掉头朝向巷口",
  [ACTIONS.BLOCK_HELPER_PATH]: "移动高脚凳卡住通道",
  [ACTIONS.ACCUSE_EARLY]: "直接指控摊主作弊",
  [ACTIONS.PUSH_AND_ESCAPE]: "推开阻挡并骑车撤离",
};

const canvas = document.querySelector("#scene");
const context = canvas.getContext("2d");
const actionsNode = document.querySelector("#actions");
const logNode = document.querySelector("#log");
const resultNode = document.querySelector("#result");
let game = createGame();

function box(x, y, width, height, color, label) {
  context.fillStyle = color;
  context.fillRect(x, y, width, height);
  context.strokeStyle = "#ffffff2e";
  context.strokeRect(x + 0.5, y + 0.5, width - 1, height - 1);
  context.fillStyle = "#ede9db";
  context.font = "16px sans-serif";
  context.fillText(label, x + 10, y + 24);
}

function person(x, y, color, label) {
  context.fillStyle = color;
  context.beginPath();
  context.arc(x, y, 17, 0, Math.PI * 2);
  context.fill();
  context.strokeStyle = "#151713";
  context.lineWidth = 4;
  context.stroke();
  context.fillStyle = "#eeeade";
  context.font = "14px sans-serif";
  context.textAlign = "center";
  context.fillText(label, x, y + 39);
  context.textAlign = "left";
}

function drawScene() {
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.fillStyle = "#6d6c5c";
  context.fillRect(0, 0, 960, 125);
  context.fillStyle = "#343731";
  context.fillRect(0, 125, 960, 415);
  context.fillStyle = "#a6a18a";
  context.font = "14px sans-serif";
  context.fillText("街道 · 撤离方向 →", 35, 68);

  box(170, 220, 510, 95, "#5d4d35", "瓜摊");
  box(402, 237, 70, 54, "#56594c", "秤");
  box(735, 185, 160, 170, "#41463d", "邻铺");
  box(705, 410, 125, 60, "#34312a", game.helperBlocked ? "高脚凳 · 已卡位" : "通道");
  box(34, 24, 120, 58, "#272921", game.exitPrepared ? "摩托 →" : "← 摩托");

  person(345, 385, "#d9b85b", "周烈");
  person(430, 175, "#b74d3f", "摊主");
  person(575, 175, "#995f50", "帮手甲");
  person(game.helperBlocked ? 760 : 645, 365, "#995f50", "帮手乙");
  if (game.witnessPresent) person(790, 150, "#5f9a8b", "修表师傅");

  if (game.facts.includes("scale_suspicious")) {
    context.strokeStyle = "#e1c258";
    context.lineWidth = 4;
    context.strokeRect(394, 229, 86, 70);
  }
  if (game.phase === "conflict") {
    context.fillStyle = "#9b382d45";
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.fillStyle = "#f0d9cf";
    context.font = "700 28px sans-serif";
    context.fillText("局势失控", 36, 505);
  }
}

function render() {
  drawScene();
  document.querySelector("#phase").textContent = game.phase;
  document.querySelector("#alert").textContent = `${game.npc.merchant.alert}/3`;
  document.querySelector("#support").textContent = `${game.npc.merchant.support}/3`;

  actionsNode.replaceChildren();
  for (const action of game.availableActions) {
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = LABELS[action];
    button.addEventListener("click", () => {
      game = performAction(game, action);
      render();
    });
    actionsNode.append(button);
  }

  logNode.replaceChildren();
  for (const entry of game.log) {
    const item = document.createElement("li");
    item.textContent = typeof entry === "string" ? entry : entry.text;
    logNode.append(item);
  }
  logNode.scrollTop = logNode.scrollHeight;

  resultNode.hidden = !game.result;
  if (game.result) {
    resultNode.innerHTML = `
      <h2>事件结束 · ${game.result.outcome}</h2>
      <p><strong>街坊版本：</strong>${game.result.streetStory}</p>
      <p><strong>警方版本：</strong>${game.result.policeStory}</p>
    `;
  }
}

document.querySelector("#restart").addEventListener("click", () => {
  game = createGame();
  render();
});

render();
