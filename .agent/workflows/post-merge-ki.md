---
description: PRマージ後にKnowledge Itemを作成する
---

# Post-merge KI Workflow

PRがマージされたら、そのPRの知見をKnowledge Item（KI）として永続化する。

## トリガー

以下のいずれかで発動：

- ユーザーが「PRがマージされた」と報告した
- `/git-commit` の Post-merge で worktree 片付け後
- エージェントが `gh pr view` でマージ済みを検出した

## 手順

// turbo
1. マージされた PR の情報を取得する

```powershell
gh pr view <number> --json title,body,headRefName,mergedAt,commits --jq "{title,body,headRefName,mergedAt,commits: [.commits[].messageHeadline]}"
```

2. PR の diff サマリーを確認する

```powershell
gh pr diff <number> --stat
```

3. 以下の観点で KI に残すべき内容を判断する

| 観点 | 含めるか | 例 |
| --- | --- | --- |
| **設計判断** | なぜこの方法を選んだか、却下した代替案 | ✅ 常に含める |
| **発見されたバグ** | 原因・修正・教訓 | ⚠️ あれば含める |
| **新しいルール/制約** | セッション中に確立されたもの | ⚠️ あれば含める |
| **ルール違反** | 何が起きて、どう対策したか | ⚠️ あれば含める |
| **未完了タスク** | 次のPRで対応すべきこと | ⚠️ あれば含める |

4. KI ディレクトリを作成する

命名規則: `<PRのスコープ>-<簡潔な説明>` （例: `setup-refactoring`, `ci-pipeline-setup`）

```
~/.gemini/antigravity/knowledge/<ki-name>/
├── metadata.json
└── artifacts/
    └── <内容に応じた .md ファイル>
```

5. `metadata.json` を作成する

```json
{
  "title": "PRタイトルまたは要約",
  "summary": "1-2文で何が記録されているか",
  "created": "ISO8601タイムスタンプ",
  "updated": "ISO8601タイムスタンプ",
  "source_conversations": ["会話ID"],
  "source_prs": ["owner/repo#番号"],
  "tags": ["関連するタグ"],
  "artifacts": ["ファイル名のリスト"]
}
```

6. アーティファクトを作成する

各 `.md` ファイルの先頭に Source（会話ID、PR番号）を明記する。
内容は **なぜそうしたか** に重点を置く。コードの What は PR diff で読める。

7. 作成した KI の内容をユーザーに報告する

## アーティファクトの粒度

- 1 PR の知見が少ない場合 → 1ファイル `summary.md` に収める
- 複数の関心事がある場合 → 関心事ごとに分割（`design_decisions.md`, `bugs_discovered.md` 等）
- 既存の KI と関連する場合 → 既存 KI の `metadata.json` の `updated` を更新し、artifacts に追記

## 既存 KI の更新

同じスコープの KI が既に存在する場合は、新規作成ではなく更新する：

1. `metadata.json` の `updated`, `source_conversations`, `source_prs` に追記
2. 既存アーティファクトに追記、または新しいアーティファクトを追加
3. 矛盾する情報があれば最新の状態に修正する

## ⚠️ 注意

- **`gh pr merge` / `gh pr ready` は絶対禁止**。このワークフローは PRが「マージされた後」に発動する。エージェントがマージすることはない
- KI はコードの What ではなく Why を記録する。diff を見れば分かることは書かない
