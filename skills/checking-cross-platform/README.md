# checking-cross-platform

コード・スクリプト・ドキュメントの OS/シェル/バージョン互換性をチェックするスキル。

## 概要

スクリプトやドキュメントを書く際に、OS・シェル・ランタイムバージョンの違いによる非互換性を検出し、クロスプラットフォーム対応のコードを提供します。

## ユースケース

- PowerShell 5.x vs 7+ の構文差異検出（`Join-Path` 3引数問題等）
- README のインストール手順を複数プラットフォーム対応に
- CI/CD の OS マトリクス設定チェック

## 構成

```
checking-cross-platform/
├── SKILL.md                              # スキル定義（4ステップワークフロー）
└── references/
    └── compatibility-checklist.md        # PS 5/7、パス区切り、シェルコマンド等の互換性表
```

## 起動条件

- シェルスクリプト (`.ps1`, `.sh`) を書くとき
- README やドキュメントに CLI コマンドを記載するとき
- CI/CD 設定ファイルを編集するとき
