# Phase 2 规则原型

该原型先验证“事实、证人、空间准备、冲突与社会叙事”之间的因果关系，不代表最终界面或演出。

## 运行测试

```bash
cd huaqiang_game/一斤八两/prototype
python -m unittest discover -s tests -v
```

## 试玩

```bash
cd huaqiang_game/一斤八两/prototype
python play.py
```

建议先尝试：

- `1, 2, 3, 4, 5`：公开证据形成不战而胜。
- `1, 3, 4, 5`：有事实但无见证，被赶走。
- `6, 7, 8, 9`：准备撤离并控制一次推搡。
- `10, 11`：预谋攻击，现场获胜但失去两种叙事。
