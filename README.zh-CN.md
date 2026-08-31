# 华强游戏实验室

[English](README.md) · [简体中文](README.zh-CN.md)

![华强游戏实验室标志](assets/huaqiang-game-lab.svg)

> 一个以证据驱动的小型游戏设计实验室，探索**社会潜行**、可解释的后果，以及原创中国工业城市背景下的高压冲突。

[![状态：实验中](https://img.shields.io/badge/状态-实验中-d6a84f)](一斤八两/README.md)
[![引擎：Godot 4.7.1](https://img.shields.io/badge/引擎-Godot%204.7.1-478cbf)](一斤八两/vertical_slice/README.md)
[![包含测试](https://img.shields.io/badge/测试-已包含-2f855a)](一斤八两/README.md)
[![许可证：AGPL v3](https://img.shields.io/badge/许可证-AGPL--3.0-only-cc0000)](LICENSE)

## 30 秒了解

本仓库是华强主题游戏实验的集合。核心项目是**《一斤八两》**：一款发生在虚构 1990 年代末工业城市“铁衡市”的第三人称社会潜行 / 动作惊悚原型。

它要验证的问题是：一场紧张冲突能否主要靠**观察、社会施压、空间准备和撤离计划**取胜，而不是依赖传统战斗循环？项目用规则原型、浏览器灰盒和 Godot 垂直切片三层实现来验证，并记录设计决策、风险和原创边界。

当前是**Phase 4 工程候选版**，不是完成品、商业发行，也不代表完成外部试玩验证。

## 内容地图

| 区域 | 用途 | 入口 |
| --- | --- | --- |
| `一斤八两/` | 主概念、设计记录、原型和垂直切片 | [游戏 README](一斤八两/README.md) |
| `一斤八两/prototype/` | 验证事实、证人、空间、冲突和叙事的 Python 规则模型 | [原型说明](一斤八两/prototype/README.md) |
| `一斤八两/greybox/` | 低依赖浏览器交互灰盒 | `npm test` 后 `npm start` |
| `一斤八两/vertical_slice/` | Godot 4.7.1 3D 可玩切片、测试和截图 | [Godot 说明](一斤八两/vertical_slice/README.md) |
| `ideas/` | 相邻短篇创意 | [创意索引](ideas/README.md) |
| `game_dev_flow.md` | 开发流程参考 | [工作流](game_dev_flow.md) |

## 为什么这样做 🎮

- **准备会改变结果：**物件位置、证人、路线和公开承诺都会影响后续事件。
- **事件会留下两种故事：**系统区分客观事实，以及证人和警方相信的版本。
- **三条可玩路线：**当前切片支持公开施压、准备后撤离，以及无准备负伤逃离。
- **三层验证：**Python 规则、浏览器灰盒和 Godot 渲染切片，让昂贵制作前的假设可检查。
- **低成本迭代：**环境有意保持程序化和灰盒质量，先验证交互与后果，再投入正式美术。

## 快速开始

前两种方式需要 Node.js 和 Python 3：

```bash
cd 一斤八两/greybox
npm test
npm start
# 打开 http://localhost:4173
```

```bash
cd 一斤八两/prototype
python -m unittest discover -s tests -v
python play.py
```

运行 3D 切片需要 **Godot 4.7.1 stable**，必要时先设置 `GODOT_BIN`：

```bash
export GODOT_BIN=/path/to/Godot_v4.7.1-stable_linux.x86_64
cd 一斤八两/vertical_slice
bash tools/run_godot.sh
bash tools/test_godot.sh
```

`WASD` / 方向键移动，鼠标旋转镜头，`E` 执行最近有效互动，`Esc` 暂停并释放鼠标。截图和 Linux 导出脚本见 Godot README。

## 视觉预览

仓库已包含垂直切片的渲染证据：

| 到达 / 互动空间 | 事件结算 |
| --- | --- |
| ![Godot 垂直切片](一斤八两/vertical_slice/screenshots/vertical_slice.png) | ![事件结算](一斤八两/vertical_slice/screenshots/resolved.png) |

更多截图见 [`vertical_slice/screenshots/`](一斤八两/vertical_slice/screenshots/)。

## 目标与不做

### 目标

- 证明一个紧凑、可重玩的社会潜行事件，并让后果易于理解。
- 让准备通过 NPC 行为和事件日志清晰可见。
- 只有在切片值得继续时，才推进 **6–8 小时**的单机 PC 游戏目标。

### 不做

- 不做开放世界犯罪沙盒、多人、持续在线服务或随机生成主线。
- 不做普通连招动作循环，也不做“找齐所有高亮线索”的流程。
- 不使用受保护的影视人物、台词、录音、音乐、肖像或镜头；见 [`一斤八两/docs/originality-and-ip.md`](一斤八两/docs/originality-and-ip.md)。

## 路线图 🧭

1. **现在——所有者验收：**完成三条路线，记录时长、清晰度和重玩意愿。
2. **下一步——切片修整：**只处理验收发现的问题，再决定低多边形和程序化音频方向是否值得继续投入。
3. **之后——制作决策：**若切片通过，规划小规模完整游戏；否则缩小、转向或停止。

最终设想是一款离线单机 PC 游戏，拥有高密度半开放街区；这只是目标，不是承诺或发行计划。

## 版本与代理协作

本集合版本为 `0.1.0`，发布记录以 [`CHANGELOG.md`](CHANGELOG.md) 为准。当前游戏的详细设计源文件是 [`一斤八两/docs/designs/`](一斤八两/docs/designs/)，阶段门和证据位于 [`一斤八两/docs/`](一斤八两/docs/)。代理可协助分流、测试、文档和已接受工作的实现，但由所有者裁决阶段门、维护者审核并合并改动。

## 注意事项

这是未完成原型。美术、动画、配音、音频和镜头都不是最终品质。Godot 仅在 Linux + 4.7.1 上验证，其他平台未验证。自动化测试不能证明好玩、市场需求、无障碍完整度或所有者验收。不要从仓库内容推断融资、授权、外部试玩、发行日期或正式制作批准。

## 参与贡献

请先阅读 [`一斤八两/CONTRIBUTING.md`](一斤八两/CONTRIBUTING.md)。保持改动小而有证据，遵守阶段门，不要加入未授权媒体或受保护原作的实质性衍生内容。文档、可复现测试和描述清楚的设计实验尤其欢迎。

提交 issue 请说明受影响路径、复现步骤和证据；PR 请说明影响哪个阶段门，并附最小相关测试或截图。本批次不虚构新的 Bilibili 上传或 arXiv 论文；现有截图和音频仍需核查来源。

## 许可证

除非嵌套内容另有说明，本集合使用 [GNU Affero General Public License v3.0 only](LICENSE)。
