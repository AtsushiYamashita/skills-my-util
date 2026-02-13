# Shift-Left Checklist

品質・セキュリティ・テストを開発初期から組み込むためのチェックリスト。

## セキュリティ

- [ ] **依存関係スキャン** — `npm audit` / `pip audit` / Dependabot を CI に組み込み
- [ ] **シークレット検出** — `gitleaks` or `truffleHog` を pre-commit フックに
- [ ] **静的セキュリティ解析** — SAST ツール（Semgrep, CodeQL）を CI に
- [ ] **最小権限** — IAM/RBAC をデフォルト deny で設計
- [ ] **入力検証** — バリデーションライブラリ（zod, joi）を共通基盤として導入

## テスト

- [ ] **テストフレームワーク** — プロジェクト初日にセットアップ（vitest, pytest, etc.）
- [ ] **テストカバレッジ** — CI でカバレッジ計測、閾値設定
- [ ] **テスト分類** — unit / integration / E2E の境界を定義
- [ ] **テストデータ** — fixture / factory パターンを共通化
- [ ] **CI実行** — テストが通らないとマージ不可

## コード品質

- [ ] **Linter** — ESLint / Ruff を CI + pre-commit に
- [ ] **Formatter** — Prettier / Black を保存時自動実行に
- [ ] **型チェック** — TypeScript strict mode / mypy を CI に
- [ ] **コミットルール** — Conventional Commits を commitlint で強制

## ドキュメント

- [ ] **API ドキュメント** — OpenAPI spec / JSDoc / docstring を CI で生成・検証
- [ ] **ADR** — 技術選定を `docs/decisions/` に記録する運用を初日から
- [ ] **README** — セットアップ手順が最新であることを CI で検証（optional）

## 適用タイミング

| タイミング | やること |
| --- | --- |
| **Day 1** | テストフレームワーク、linter/formatter、型チェック |
| **Week 1** | CI パイプライン、依存関係スキャン、シークレット検出 |
| **Before MVP** | SAST、カバレッジ閾値、コミットルール |
| **Before Production** | すべてのチェック項目が ✅ |
