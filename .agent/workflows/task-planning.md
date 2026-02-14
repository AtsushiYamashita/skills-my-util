---
description: 非自明なタスクに Gantt chart を作成し、進捗を可視化する
why: タスクの全体像・ボトルネック・人間ゲートを明示し、セッション中断に耐える
for: 非自明なタスクの開始時
related: Issue #24
---

# Task Planning

非自明なタスクには **mermaid Gantt chart** をタスクファイルに含める：

- **Planned**, **active** (`active`), **critical path** (`crit`)
- **Human gates** — `milestone` で人間承認のボトルネックを明示

```mermaid
gantt
    title Example
    section Done
    Requirements       :done, h1, 2024-01-01, 1d
    section In Progress
    Design             :active, a1, after h1, 2d
    section Blocked
    User approval      :milestone, m1, after a1, 0d
    section Upcoming
    Implementation     :crit, i1, after m1, 3d
```

## Rules

- Gantt chart は**永続ファイル**に書く（`task.md`）— セッション中断に耐える
- セッション開始時に**既存タスクファイルを確認** — あれば前回の状態から再開
- `milestone` には**誰が**ブロックしていて**何を**決める必要があるかを記載
- **各フェーズ完了後**にチャートを更新（開始時だけではない）
