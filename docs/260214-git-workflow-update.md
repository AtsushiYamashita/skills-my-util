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

#### 3. 階層分割 — 現時点では不要

**Why not:**
- 現在の `git-strategies.md` は168行。1ファイルで十分読める
- 分割すると参照コストが上がる（エージェントが複数ファイルを `view_file` する必要）
- `git-commit.md` ワークフローは既に分離済み

**反論:** Issue は分割を提案している。
→ Issue の提案は「将来の拡張余地」のための構造。
  現時点で肥大化していないなら、YAGNIの原則で据え置き。
  200行を超えたら分割を検討する。

**結論:** 分割しない。Issue にコメントで理由を記載。

#### 4. 全体ワークフロー — 追加する

Issue の「ワークフロー素案」はセッション全体の流れを定義している：
1. pull → 2. 古いworktree掃除 → 3. Issue確認/作成 → 4. ブランチ/worktree作成 → 5. 作業 → 6. commit → 7. push & PR

現状の `git-commit.md` はステップ6のみ。全体フローがない。
→ `git-session.md` ワークフローとして追加する。

## 変更計画

### 変更1: ブランチ命名規則を `git-strategies.md` に追記
- L83-90 のブランチテーブルを更新
- `<type>/<descriptive-name>` を基本、Issue ある場合は `issue-<N>-<desc>` を推奨

### 変更2: `git-session.md` ワークフローを新規作成
- セッション開始（pull, cleanup）→ 作業 → 終了（push, PR）の全体フロー
- `git-commit.md` は既存のまま、session から参照

### 変更3: Issue #19 にコメント
- 階層分割を見送る理由を記載
- 完了した項目を報告
