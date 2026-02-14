---
description: 変更をコミットする（Git 運用ルール準拠）
---

# Git Commit Workflow

変更をコミットする前に、必ずこのワークフローに従う。

## Pre-flight

// turbo
1. 現在のブランチとワークツリーを確認する

```powershell
git branch --show-current; git worktree list
```

2. **main にいる場合 → 中止**。worktree を作成してから再開する

```powershell
git worktree add ../$(Split-Path -Leaf (Get-Location))-feat-xxx -b feat/xxx
```

3. ブランチ名と作業内容が一致しているか確認する

| 作業内容 | 正しい接頭辞 |
| --- | --- |
| 新機能 | `feat/` |
| バグ修正 | `fix/` |
| ドキュメント | `docs/` |
| リファクタ | `refactor/` |
| ルール・設定 | `rule/` |

// turbo
4. このブランチに既存の PR がある場合、**マージ/クローズ済みでないか**確認する

```powershell
gh pr list --head $(git branch --show-current) --state all --json number,state,title
```

**MERGED / CLOSED の場合 → このブランチにはコミットしない。** 新しいブランチを作成する。

## Commit

// turbo
5. 変更内容を確認する

```powershell
git status; git diff --stat
```

6. 意味単位でステージングする（`git add .` は原則禁止）

```powershell
git add <file-or-directory>
```

7. コミットメッセージを作成する（Conventional Commits + Why）

```powershell
git commit -m "type(scope): what" -m "Why: なぜこの変更が必要か"
```

## Commit Timing（いつコミットするか）

以下のタイミングで即コミット：

1. **動作確認が取れた**とき — 壊れない状態を保護する
2. **方向転換する前** — 戻れるセーブポイントを作る
3. **1つの作業単位が完了した**とき — 中途半端にしない

## Post-commit

// turbo
8. ログを確認する

```powershell
git log --oneline -3
```

9. Draft PR を作成する（完了時）

```powershell
gh pr create --draft --title "type(scope): what" --body "## What`n`n## Why`n`n## Testing"
```

## Post-merge（PR マージ確認後）

マージを確認したら **即座に** worktree を片付ける。放置すると「どの worktree が何？」問題が起きる。

// turbo
10. マージ済み PR の worktree を一覧する

```powershell
git worktree list
```

11. マージ済みの worktree を削除する

```powershell
git worktree remove <worktree-path>
git branch -d <branch-name>
```
