# skills-my-util

複数の小規模なスキルをまとめて管理するモノレポジトリ。

## 概要

AI エージェント用のスキルを一元管理し、Claude Code / Gemini CLI / Google Antigravity に対してセットアップできるリポジトリ。

## セットアップ

```powershell
# 全スキルを Gemini CLI にインストール
.\scripts\setup.ps1 -t gemini-cli

# 特定のスキルだけ Claude Code にインストール
.\scripts\setup.ps1 -t claude-code -Skills change-sync

# Antigravity にインストール
.\scripts\setup.ps1 -t antigravity

# アンインストール
.\scripts\setup.ps1 -t gemini-cli -Remove
```

> [!NOTE]
> `setup.ps1` はシンボリックリンクを使用するため、リポジトリ内の編集が即座に反映されます。
> Windows では管理者権限 or 開発者モードが必要です。

### 対応プラットフォーム

| Target        | Skill Path                                   |
| ------------- | -------------------------------------------- |
| `claude-code` | `~/.claude/skills/<skill-name>/`             |
| `gemini-cli`  | `~/.gemini/skills/<skill-name>/`             |
| `antigravity` | `~/.gemini/antigravity/skills/<skill-name>/` |

## スキル一覧

### [change-sync](skills/change-sync/)

プロジェクト内のファイル変更を宣言的ルール (`.change-sync.yml`) に基づいて自動伝播するスキル。

**ユースケース:**

- `package.json` の version 変更 → `src/version.ts`, `README.md` に同期
- DB スキーマ変更 → TypeScript 型定義を再生成
- 翻訳元ファイル変更 → 他言語ファイルに未翻訳フラグを追加

### [researching-alternatives](skills/researching-alternatives/)

新しいものを作る前に、類似プロダクト・ツール・アプローチを調査・比較するスキル。

**ユースケース:**

- 新規プロジェクトの技術選定（フレームワーク、ライブラリ比較）
- 既存ツールで代替できないか事前検証
- トレードオフ表による定量的比較と意思決定記録

### [checking-cross-platform](skills/checking-cross-platform/)

コード・スクリプト・ドキュメントの OS/シェル/バージョン互換性をチェックするスキル。

**ユースケース:**

- PowerShell 5.x vs 7+ の構文差異検出（`Join-Path` 3引数問題等）
- README のインストール手順を複数プラットフォーム対応に
- CI/CD の OS マトリクス設定チェック

### [enforcing-code-standards](skills/enforcing-code-standards/)

コード品質・ロギング・TypeScript 型安全・関数型スタイル・Conventional Commits を強制するスキル。GEMINI.md Principle V-A/V-B から抽出。

### [designing-architecture](skills/designing-architecture/)

ドメイン駆動設計・オニオンアーキテクチャ・インターフェース設計・Spike Before Commit を案内。GEMINI.md Principle V-C から抽出。

### [reviewing-safety](skills/reviewing-safety/)

環境安全・爆発半径最小化・多層防御・テストピラミッド戦略。GEMINI.md Principle V-D/V-E から抽出。

## ディレクトリ構造

```
skills-my-util/
├── .agent/                 # エージェント設定
│   ├── rules/             # 永続ルール
│   │   ├── preflight-check.md    # 実行前チェック
│   │   ├── skill-quality-gate.md # 品質ゲート
│   │   └── git-strategies.md     # Git ルール
│   └── workflows/
│       └── new-skill.md   # /new-skill ワークフロー
├── skills/                 # 全スキル
│   └── <skill-name>/
│       ├── SKILL.md       # スキル定義（必須）
│       ├── references/    # 詳細仕様（任意）
│       ├── scripts/       # ヘルパースクリプト（任意）
│       └── examples/      # ルールサンプル（任意）
├── docs/
│   ├── skill-quality-guide.md  # 品質基準
│   └── references.md          # 参考リンク集
├── scripts/
│   ├── setup.ps1          # マルチプラットフォーム セットアップ
│   └── new-skill.ps1      # スキル雛形生成
├── MEMORY/                 # セッションログ
└── README.md
```

## 新しいスキルの作成

```powershell
.\scripts\new-skill.ps1 -SkillName "my-new-skill"
```

または、エージェントから `/new-skill` ワークフローを使用してください。

## 品質基準

スキルは [Agent Skills 仕様](https://agentskills.io/specification) と [Anthropic Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) に準拠する必要があります。

詳細: [docs/skill-quality-guide.md](docs/skill-quality-guide.md)

## ライセンス

[MIT](LICENSE)
