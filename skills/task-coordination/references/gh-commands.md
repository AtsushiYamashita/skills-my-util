# gh CLI Reference

Task coordination で使用する `gh` コマンドのリファレンス。

境界設計: [docs/task-state-boundary.md](../../../docs/task-state-boundary.md)

## Label Taxonomy

ラベルは**分類と通知**に使う。状態管理には使わない（→ CozoDB）。

| Label | Color | Purpose |
| --- | --- | --- |
| `blocked:human` | `#B60205` | 人間のアクションが必要（通知トリガー） |
| `blocked:external` | `#E99695` | 外部依存待ち |
| `critical-path` | `#FBCA04` | 遅延がプロジェクト全体に影響 |
| `priority:high` | `#D93F0B` | 次に着手すべき |

### 廃止済み

`status:planned`, `status:in-progress`, `status:blocked` — GitHub の Open/Closed + CozoDB が代替。

### Label Setup

新しいリポジトリにラベルを一括作成:

```bash
gh label create "blocked:human"    --color "B60205" --description "Human action required" --force
gh label create "blocked:external" --color "E99695" --description "Waiting on external dependency" --force
gh label create "critical-path"    --color "FBCA04" --description "Delay here delays everything" --force
gh label create "priority:high"    --color "D93F0B" --description "Should be picked up next" --force
```

### Label Rules

- taxonomy にないラベルは勝手に作らない
- ラベルの追加・変更はユーザーに確認してから
- 他のリポからコピーする場合: `gh label clone SOURCE_REPO`

## Issue Operations

### Create

```bash
gh issue create \
  --title "feat: implement auth" \
  --body "## Acceptance Criteria
- [ ] Login/logout works
- [ ] Token refresh handled" \
  --label "priority:high"
```

**ルール**:
- タイトルは `type: what` フォーマット（Conventional Commits に準拠）
- body に Acceptance Criteria を必ず含める
- 状態ラベルは付けない（Open = 未完了、Closed = 完了）

### Block

```bash
gh issue comment 42 --body "Blocked: waiting for @user to approve design doc"
gh issue edit 42 --add-label "blocked:human"
```

### Complete

```bash
gh issue close 42 --comment "Done: implemented auth with Firebase. PR #10"
```

## Issue Check on Session Start

**Issue-driven の核心**: 作業開始前に必ず既存 Issue を確認し、関連性をチェックする。

### Step 1: Open Issues を取得

```bash
gh issue list --state open --json number,title,labels,assignees --limit 50
```

### Step 2: 関連性を判断

取得した Issue リストに対して:

1. **自分に assign されている** → 優先的に着手（前回の続き）
2. **`blocked:human` ラベル** → ユーザーに即報告
3. **`priority:high` ラベル** → 着手候補として提示
4. **今の作業と関連する** → リンクまたは重複を確認

### Step 3: 重複チェック

新しい Issue を作る前に、既存 Issue との重複を確認:

```bash
gh search issues "keyword" --repo OWNER/REPO --state open --json number,title
```

重複がある場合:
- 同じ目的 → 既存 Issue に合流（新規作成しない）
- 部分的に重複 → コメントで相互参照を付ける
- 関連あるが別タスク → 新規作成して `Relates to #N` を body に記載

## PR Operations

### Draft PR（エージェントのデフォルト）

```bash
gh pr create \
  --base main \
  --head feat/xxx \
  --draft \
  --title "feat: what this PR does" \
  --body "## Summary
What and why.

## Changes
- File changes listed

## Related
Closes #42"
```

**ルール**:
- エージェントは **Draft PR のみ** 作成する
- `Closes #N` で Issue を自動リンク
- マージは人間が判断

### PR Status Check

```bash
gh pr list --state open --json number,title,headRefName,isDraft
gh pr view 1 --json state,mergeable,reviewDecision
```

## Cross-Repo Search

```bash
# Issue 検索（キーワード）
gh search issues "auth" --owner AtsushiYamashita --state open

# PR 検索
gh search prs "refactor" --repo OWNER/REPO --state open

# コミット検索
gh search commits "fix login" --repo OWNER/REPO
```

## Anti-Patterns

- ❌ taxonomy にないラベルを勝手に作る
- ❌ Acceptance Criteria なしの Issue
- ❌ 既存 Issue を確認せずに新規作成（重複の原因）
- ❌ PR を Ready にする（Draft のみ）
- ❌ Issue を Close せずに PR だけマージ（`Closes #N` を使う）
- ❌ status:* ラベルを使う（廃止済み）
