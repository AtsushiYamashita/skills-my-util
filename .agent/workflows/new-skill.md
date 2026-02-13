---
description: 新しいスキルを skills/ ディレクトリに作成する
---

# New Skill Creation

テンプレートリポジトリから新しいスキルのひな形を生成します。

## Steps

1. スキル名を決定する（小文字、ハイフン区切り、例: `my-awesome-skill`）

// turbo 2. スキル生成スクリプトを実行する

```powershell
.\scripts\new-skill.ps1 -SkillName "<skill-name>"
```

3. `skills/<skill-name>/SKILL.md` を編集して以下を記述する:
   - `description` フィールド: いつ・なぜこのスキルが起動されるべきか
   - Overview: スキルの目的
   - Usage: 使用方法と具体例

4. 必要に応じてサブディレクトリを追加する:
   - `scripts/` - ヘルパースクリプト
   - `examples/` - 参考実装
   - `docs/` - スキル固有のドキュメント

5. コミットする

```powershell
git add skills/<skill-name>
git commit -m "feat: add <skill-name> skill"
```
