# git-workflow-update: Issue #19 解決計画

## Topic: git-strategies.md に何が欠落していて、何を追加・変更するか

### スコープ

Issue #19 は「Anti-Patterns もブランチ命名規則も欠落」と題しているが、
現状の `git-strategies.md` を確認した結果、**欠落の度合いは項目により異なる**：

| 項目 | 現状 | Issue の要求 | 差分 |
|---|---|---|---|
| Anti-Patterns | ✅ L158-168 に8項目 | 8項目 | **一致。追加不要** |
| ブランチ命名規則 | ⚠️ `feat/add-xxx` 形式 | `<type>/issue-<N>` 形式 | **要検討** |
| 階層分割 | ❌ 1ファイル168行 | entry + サブファイル群 | **要検討** |
| 全体ワークフロー | ❌ git-commit.md のみ | セッション開始〜終了 | **追加候補** |

### Why: 各項目の判断

#### 1. Anti-Patterns — 追加不要
現状の8項目は Issue の要求と完全一致。これ以上は過剰。

#### 2. ブランチ命名規則 — 選択肢の整理

| 選択肢 | 特徴 | 問題 |
|---|---|---|
| A: `<type>/issue-<N>` | Issue番号で一意に特定可能 | Issue がない作業（typo修正など）に不自然 |
| B: `<type>/<descriptive-name>` | 目的が読める | 同じ目的のブランチ名が被る可能性 |
| C: 併用 `<type>/<descriptive>-<N>`（Issueがあれば末尾に番号） | 柔軟 | ルールが曖昧になりうる |

**現在の `git-strategies.md` のブランチ名テーブル**（L85-90）:
```
feat/add-xxx, fix/resolve-xxx, docs/fix-xxx, experiment/try-xxx
```
**Issue #19 の参考セクション** の命名規則:
```
<type>/issue-<number>
```

**反論:** Issue #19 の参考は別リポジトリ（degipa-mock）のルール。
skills-my-util にそのまま適用すべきか？
→ Issue番号ベースは**トレーサビリティが高い**が、
  このリポジトリは1人+AI開発で、Issue がない微修正も多い。

**結論:** C を採用。`<type>/<descriptive-name>` を基本とし、
Issue がある場合は `<type>/issue-<N>-<short-desc>` を推奨。
例: `feat/issue-19-git-restructure`, `fix/typo-readme`

#### 3. 階層分割 — ~~不要~~ → **必要（修正）**

**初回判断（誤り）:** 168行で分割不要、YAGNI。

**見落としていた Why:**
Issue #19 の階層構造提案は **Agent swarm（複数エージェントの並行作業）** を前提としていた。
Issue にも計画にも Why が明記されず、双方が Action だけを見ていた。

**なぜ階層分割が必要か:**

1. **タイミング別の参照制限** — ブランチ作成時は `branch-naming.md` だけ読めばよい
2. **並行作業の安全性** — 複数エージェントが「今の自分のフェーズで何を守るべきか」を明確にする
3. **エントリポイントが状況ルーティング** — 「今何をしている？」→ 該当ファイルだけ参照

**結論:** Issue #19 の提案通り、階層構造に分割する。

#### 4. 全体ワークフロー — 追加する（実装済み）

`git-session.md` ワークフローとして追加済み。

## 教訓（Why-first）

互いに Action に目を向けすぎて Why を共有できなかった。
→ KI `why-first-communication` に記録済み。

## 変更計画（修正版）

### 変更1: ブランチ命名規則の追記（実装済み）

### 変更2: `git-strategies.md` を階層分割

- `git-strategies.md` → エントリポイント（状況振り分けのみ）
- `git-workflows/branch-naming.md` — ブランチ命名規則
- `git-workflows/pre-commit.md` — コミット前チェック
- `git-workflows/merge-strategy.md` — マージ戦略・PR ルール
- `git-workflows/worktree.md` — Worktree 運用ルール

### 変更3: `git-session.md` 新規作成（実装済み）

### 変更4: `git-commit.md` の同期（実装済み）

