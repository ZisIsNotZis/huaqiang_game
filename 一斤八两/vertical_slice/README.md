# Godot 垂直切片基础版

## 当前内容

- Godot 4.7.1 项目。
- 完整第一章流程：动机、准备、现场取证、公开压力与后果复盘。
- 可移动的第三人称灰盒角色和跟随相机。
- 一条原创街市、瓜摊、秤、修表铺、摩托和通道。
- 基于玩家距离的实体互动、逐步事件状态、NPC警觉、帮手支持、证人出现和双版本结算。
- 冲突警示、帮手逼近、撤离位移动画、检查点写入和事件重开。
- 摊主距离 / 视角 / 物理遮挡感知及其可解释原因。
- 瓜摊、建筑、道路和玩家具有基础碰撞体。
- 偷看秤与移动木凳只有在被看见时才增加警觉。
- 声音按距离、响度和遮挡衰减；拖动木凳即使不可见也可能被听见。
- 警觉达到阈值后摊主会主动靠近玩家。
- 冲突根据退路、卡位和对手支持计算无伤、轻伤或重伤。
- 未准备的对峙不再死锁；玩家可以负伤逃离并把伤势带入结果。
- 运行时只选择距离最近的有效互动，目标以发光材质高亮并显示高对比度 `E` 提示。
- 设置面板支持持久化主音量、80%–140%文字缩放和减少运动。
- `E` 单一互动键、`Esc` 暂停、检查点读取。
- 非暴力公开揭露与准备后的受控撤离规则。
- Godot 内部自动测试与可重复截图。
- 程序化环境声与按行动分类的提示音。
- 带版本、校验、旧格式迁移和损坏提示的检查点。
- 三条完整结局路径及后续章节钩子。

当前为 **Phase 4 工程候选版**。进入 Phase 5 前仍需所有者完成三路线试玩并确认时长、乐趣与代表性品质。

## 获取 Godot

项目验证版本：

```text
Godot 4.7.1 stable
SHA-256 c7ff14fd28472c8d4f193043de30278dcf7e5241a1dcf7566b02e27addaa33ba
```

可设置：

```bash
export GODOT_BIN=/path/to/Godot_v4.7.1-stable_linux.x86_64
```

## 运行

```bash
bash tools/run_godot.sh
```

操作：

- `WASD` 或方向键移动。
- 移动鼠标环绕和俯仰第三人称相机；`Esc` 释放鼠标并暂停。
- 靠近当前有效目标后，最近目标会高亮并显示 `E` 提示。
- 右侧按钮执行当前可用的社会 / 空间行动。

## 测试

```bash
bash tools/test_godot.sh
```

## 自动截图

```bash
bash tools/capture_godot.sh
```

截图写入 `screenshots/vertical_slice.png`、`screenshots/resolved.png`、`screenshots/injured.png`、`screenshots/highlight.png` 和 `screenshots/settings.png`。

## Linux 构建

安装 Godot 4.7.1 官方导出模板后运行：

```bash
bash tools/export_linux.sh
```

可执行文件写入 `build/yijin_baliang.x86_64`。
