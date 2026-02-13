# skills-my-util

複数の小規模なスキルをまとめて管理するモノレポジトリ。

## 概要

このリポジトリは、AI エージェント用の小規模なスキルを一元管理するために設計されています。各スキルは `skills/` ディレクトリ配下に独立したディレクトリとして配置されます。

## ディレクトリ構造

```
skills-my-util/
├── .agent/              # ワークスペース共有のエージェント設定
│   ├── rules/          # 永続的ルール（.gitignore対象）
│   └── workflows/      # 再利用可能なワークフロー
├── skills/              # 全スキルの親ディレクトリ
│   └── <skill-name>/   # 各スキル（SKILL.md 必須）
├── docs/                # 共有ドキュメント・参考資料
└── scripts/             # リポジトリ管理用スクリプト
```

## 新しいスキルの作成

```powershell
.\scripts\new-skill.ps1 -SkillName "my-new-skill"
```

または、エージェントから `/new-skill` ワークフローを使用してください。

## スキル構造

各スキルは以下の構造に従います:

```
skills/<skill-name>/
├── SKILL.md       # スキル定義（必須）
├── scripts/       # ヘルパースクリプト（任意）
├── examples/      # 参考実装（任意）
└── docs/          # スキル固有ドキュメント（任意）
```

## ライセンス

[MIT](LICENSE)
