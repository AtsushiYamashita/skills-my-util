---
why: main への直接コミットを構造的に防止する
for: git commit 実行前
related: Issue #19
---

# Pre-commit Check（コミット前に必ず実行）

`git commit` を実行する前に、以下を**毎回**確認する：

1. **worktree 内にいるか？** — `git worktree list` でカレントディレクトリが worktree であることを確認
2. **メインディレクトリにいる → コミットしない**。worktree を作成してから再開
3. **ブランチ名と作業内容が一致しているか？** — `git branch --show-current` で確認

| 作業内容 | 正しいブランチ | 間違い |
| --- | --- | --- |
| 新機能追加 | `feat/xxx` | `main`, `fix/xxx` |
| バグ修正 | `fix/xxx` | `main`, `feat/xxx` |
| ドキュメント更新 | `docs/xxx` | `main` |
| リファクタ | `refactor/xxx` | `main` |
| ルール変更 | `rule/xxx` | `main` |

**間違った worktree にいる場合**: 正しい worktree のディレクトリに移動する（stash/checkout ではない）

## Commit Timing（いつコミットするか）

以下のタイミングで即コミット：

1. **動作確認が取れた**とき — 壊れない状態を保護する
2. **方向転換する前** — 戻れるセーブポイントを作る
3. **1つの作業単位が完了した**とき — 中途半端にしない
