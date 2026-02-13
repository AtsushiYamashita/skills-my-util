# enforcing-code-standards

コード品質・ロギング・TypeScript 型安全・関数型スタイル・Conventional Commits を強制するスキル。

## 概要

GEMINI.md Principle V-A (Methods) と V-B (Code Quality) から抽出。コードを書く・レビューするすべての場面で適用される 13 項目の品質基準を定義します。

## 主な基準

- Production-grade コード（入力検証、エラーハンドリング、最小権限）
- 関心の分離（純粋関数 vs I/O、ドメイン vs 汎用）
- ドキュメントコメント（JSDoc / docstring）
- 構造化ロギング（レベル、必須フィールド、NG 項目）
- TypeScript 型安全（`any` 禁止、`unknown` + narrowing）
- 関数型・イミュータブルスタイル
- Conventional Commits

## 構成

```
enforcing-code-standards/
├── SKILL.md                           # スキル定義（13項目チェックリスト）
└── references/
    └── logging-standards.md           # 構造化ロギングの詳細仕様
```

## 起動条件

- コードを書くとき（全言語）
- コードレビュー・リファクタリング時
- プロジェクトツーリング設定時
