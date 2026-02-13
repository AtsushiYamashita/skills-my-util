# reviewing-safety

環境安全・爆発半径最小化・多層防御・テストピラミッド戦略を適用するスキル。

## 概要

GEMINI.md Principle V-D (Safety) と V-E (Testing) から抽出。セキュリティレビュー、テスト設計、共有モジュール変更時に適用される 4 つの安全基準を定義します。

## 基準

1. **Environment-Safe Scripting** — グローバル状態を汚染しない、べき等なスクリプト
2. **Blast Radius Minimisation** — 変更の影響範囲を最小化
3. **Defense in Depth** — 全レイヤーで独立した防御
4. **Test Pyramid** — Unit > Integration > E2E の比率を維持

## 構成

```
reviewing-safety/
└── SKILL.md    # スキル定義（4基準 + テストピラミッド図）
```

## 起動条件

- シェルスクリプトの作成・レビュー時
- セキュリティに関わるコードの変更時
- テスト戦略の設計・レビュー時
- 共有モジュールの変更時
