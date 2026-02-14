---
description: Git セッションの開始から終了までの全体フロー
---

# Git Session Workflow

セッション開始時、作業中、終了時の全体的な流れ。

## セッション開始

// turbo
1. main を最新にする

```powershell
git checkout main; git pull origin main
```

2. マージ済みの worktree・ブランチを掃除する

```powershell
git worktree list
```

マージ済みの worktree があれば削除する：

```powershell
git worktree remove <worktree-path>
git branch -d <branch-name>
```

## 作業目標の確認

3. Issue を確認する

```powershell
gh issue list --assignee @me --state open
```

- ユーザーの指示があれば → Issue を作成して自分に割り当て
- なければ → 未割り当ての Issue を自分に割り当て
- なければ → テスト追加やリファクタの Issue を起票

## 作業環境

4. 作業用ブランチと worktree を作成する

```powershell
git worktree add ../$(Split-Path -Leaf (Get-Location))-<type>-<desc> -b <type>/<desc>
```

命名規則は `.agent/rules/git-strategies.md` の「ブランチ命名規則」に従う。

## 作業中

5. atomic commit ルールに従い、意味単位でコミットする

→ `/git-commit` ワークフローに従う

## 作業完了

6. push して Draft PR を作成する

```powershell
git push -u origin $(git branch --show-current)
gh pr create --draft --title "<type>(scope): what" --body "Closes #<N>"
```

7. main に戻って次の作業に移る

```powershell
git checkout main; git pull origin main
```
