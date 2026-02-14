---
why: Git 運用の地図。状況に応じた詳細ルールへのルーティング
for: Git 操作を行う前
related: Issue #19, Issue #24
---

# Git Strategies

Git 運用のエントリポイント。状況に応じて詳細ルールを参照する。

## Atomic Commits（意味単位のコミット）

1コミット = 1つの意味のある変更。以下のテストを満たすこと：

- **読める**: diff を見て「何をしたか」が30秒で分かる
- **戻せる**: このコミットだけ revert しても壊れない
- **説明できる**: コミットメッセージが1行で書ける
- **意図がある**: Why（なぜこの変更か）を書く。What だけでは不十分

### 定量ガイドライン（超えたら分割必須）

| 指標 | 上限 | 備考 |
| --- | --- | --- |
| diff の変更行数 | **100行** | 新規・既存とも同じ |
| 変更ファイル数 | **3ファイル** | |
| 新規ファイル | **1コミット1ファイル** | 既存ファイル修正と混ぜない |

### コミットメッセージのフォーマット

```
type(scope): what

Why: なぜこの変更が必要か（1-2行）
```

## 詳細ルール（状況に応じて参照）

| 状況 | 参照先 |
| --- | --- |
| ブランチを作成する | `.agent/rules/git-workflows/branch-naming.md` |
| コミットする | `.agent/rules/git-workflows/pre-commit.md` |
| PR・マージする | `.agent/rules/git-workflows/merge-strategy.md` |
| worktree を操作する | `.agent/rules/git-workflows/worktree.md` |

## ワークフロー

| 状況 | 参照先 |
| --- | --- |
| セッション全体の流れ | `.agent/workflows/git-session.md` |
| コミット手順 | `.agent/workflows/git-commit.md` |

## Anti-Patterns

- ❌ main に直接コミット（typo でも例外なし）
- ❌ メインディレクトリで `git checkout -b` して作業（worktree を使う）
- ❌ 動作確認前にコミット（壊れた状態を保存しない）
- ❌ 長時間コミットしない（クラッシュ時にすべて失う）
- ❌ WIP コミットを大量に積む（後でまとめることを前提にしない）
- ❌ エージェントが PR をマージする（人間の判断を奪わない）
- ❌ 1つの worktree で複数ブランチを切り替える
- ❌ PR済みブランチを使い回して別の変更を積む
