# Skill Quality Gate

スキルの完成報告前に必ず実行する品質チェック。

---

## Trigger

以下のいずれかの**前**にこのチェックを実行する:

- 「スキルが完成しました」とユーザーに報告する
- スキル関連ファイルをコミットする

## Procedure

### 1. Preflight Check（前提）

`.agent/rules/preflight-check.md` のチェックリストを先に完了していること。

### 2. Quality Checklist

`docs/skill-quality-guide.md` のチェックリストに照合する:

```
□ name フィールドが存在し、lowercase で、ディレクトリ名と一致するか？
□ description が third-person で、trigger keywords を含むか？
□ SKILL.md body が 500行以下か？
□ 詳細な仕様は references/ に分離されているか？（progressive disclosure）
□ パスが全て forward-slash か？
□ 具体的な例があるか（抽象的でないか）？
□ 時間依存の情報が含まれていないか？
```

### 3. Self-Test

実際のユースケースを想定し、スキルの指示に従って1件以上のシナリオを検証する。

### 4. Report Format

品質チェックの結果を以下の形式で報告する:

```
## Quality Check Results

| Item                        | Status |
|-----------------------------|--------|
| name field                  | ✅/❌  |
| description (3rd person)    | ✅/❌  |
| SKILL.md under 500 lines    | ✅/❌  |
| Progressive disclosure      | ✅/❌  |
| Forward-slash paths         | ✅/❌  |
| Concrete examples           | ✅/❌  |
| No time-sensitive content   | ✅/❌  |
| Self-test passed            | ✅/❌  |
```

---

## Enforcement

品質チェック結果の報告なしにスキル完成を宣言することは許容されない。
