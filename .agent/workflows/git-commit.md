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

## Commit

// turbo
4. 変更内容を確認する

```powershell
git status; git diff --stat
```

5. 意味単位でステージングする（`git add .` は原則禁止）

```powershell
git add <file-or-directory>
```

6. コミットメッセージを作成する（Conventional Commits + Why）

```powershell
git commit -m "type(scope): what" -m "Why: なぜこの変更が必要か"
```

## Post-commit

// turbo
7. ログを確認する

```powershell
git log --oneline -3
```

8. Draft PR を作成する（完了時）

```powershell
gh pr create --draft --title "type(scope): what" --body "## What`n`n## Why`n`n## Testing"
```
