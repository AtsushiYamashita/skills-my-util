---
description: タスク状態を CozoDB に記録・追跡する
why: やりかけ放置・やったつもり・終わったつもりを防ぐ
for: タスク開始時、完了時、セッション開始時、ブロック/放棄時
related: Issue #24
---

# Task State Tracking

## State Machine

```
planned → in_progress → done
                ↓
             blocked → in_progress (再開)
                ↓
             abandoned (明示的に放棄)
```

有効な遷移のみ許可。`in_progress` → `done` には **evidence（完了の証拠）** が必須。

## タスク開始時

```
cozo_put tasks [[id, title, "in_progress", assignee, now, now, ""]]
cozo_put task_transitions [[id, now, "planned", "in_progress", "作業開始"]]
```

## タスク完了時

evidence（コミットハッシュ、テスト結果等）を記録する：

```
cozo_put tasks [[id, title, "done", assignee, created, now, "commit:abc123"]]
cozo_put task_transitions [[id, now, "in_progress", "done", "完了: <要約>"]]
```

**evidence が空の `done` は許可しない。**

## セッション開始時

孤立した `in_progress` タスクを検出する：

```
cozo_query "?[id, title, assignee, updated_at] := tasks[id, title, 'in_progress', assignee, _, updated_at, _]"
```

結果があれば → ユーザーに即座にサーフェスする：
「前回のセッションで以下のタスクが進行中のまま残っています。再開しますか？放棄しますか？」

## ブロック/放棄時

```
cozo_put task_transitions [[id, now, "in_progress", "blocked", "理由: <何に/誰にブロックされているか>"]]
cozo_put task_transitions [[id, now, "in_progress", "abandoned", "理由: <なぜ放棄するか>"]]
```

## User Decision Prediction

ユーザーの判断を**予測して先に動く**。不要な確認で作業を止めない。

1. **質問する前に**過去の判断パターンを CozoDB `user_decisions` で確認する
2. 一貫したパターンがあれば → **質問せず実行** + 事後報告
3. パターンが不明 or 矛盾 → 確認する
4. 確認した結果を記録し、次回の予測精度を上げる

| 条件 | 行動 |
| --- | --- |
| 同じ context で同じ answer が3回以上 | 予測して実行 |
| answer がバラバラ | 確認する |
| 初めての context | 確認する → 結果を記録 |

## Anti-Patterns

- ❌ evidence なしで `done` にする — 「やったつもり」の原因
- ❌ `in_progress` のまま別タスクを始める — 「やりかけ放置」の原因
- ❌ ステータス変更時に `task_transitions` を記録しない — 監査証跡がなくなる
- ❌ 答えが明白な質問で作業を止める — 過去の判断パターンを確認してから聞く
