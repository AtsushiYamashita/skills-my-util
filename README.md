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

| スキル                                                       | 概要                                               | 起動条件                                  |
| ------------------------------------------------------------ | -------------------------------------------------- | ----------------------------------------- |
| [change-sync](skills/change-sync/)                           | ファイル変更を `.change-sync.yml` ルールで自動伝播 | ファイル間同期ルールの定義・実行時        |
| [researching-alternatives](skills/researching-alternatives/) | 実装前に類似ツール・アプローチを調査・比較         | 新規技術選定、既存代替の検証時            |
| [checking-cross-platform](skills/checking-cross-platform/)   | OS/シェル/バージョン互換性チェック                 | スクリプト・ドキュメント・CI 設定の作成時 |
| [enforcing-code-standards](skills/enforcing-code-standards/) | コード品質・ロギング・型安全・コミット規約         | コードの作成・レビュー時                  |
| [designing-architecture](skills/designing-architecture/)     | ドメイン駆動・オニオン・インターフェース・Spike    | プロジェクト・モジュール設計時            |
| [reviewing-safety](skills/reviewing-safety/)                 | 環境安全・爆発半径・多層防御・テスト戦略           | セキュリティレビュー・テスト設計時        |
| [orchestrating-agents](skills/orchestrating-agents/)         | Supervisor/Worker パターンで6フェーズ委任          | 複数関心事にまたがる非自明なタスク        |

各スキルの詳細は `skills/<skill-name>/README.md` を参照してください。

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
