# change-sync

プロジェクト内のファイル変更を宣言的ルール (`.change-sync.yml`) に基づいて自動伝播するスキル。

## 概要

ファイル間の依存関係を YAML で定義し、ソースファイルの変更時に関連ファイルへ自動的に変更を伝播します。

## ユースケース

- `package.json` の version 変更 → `src/version.ts`, `README.md` に同期
- DB スキーマ変更 → TypeScript 型定義を再生成
- 翻訳元ファイル変更 → 他言語ファイルに未翻訳フラグを追加

## 構成

```
change-sync/
├── SKILL.md              # スキル定義
├── references/
│   └── rule-format.md    # ルール記法の詳細仕様
└── examples/
    ├── version-sync.yml  # バージョン同期の例
    ├── schema-types.yml  # スキーマ → 型定義の例
    └── i18n-sync.yml     # 多言語同期の例
```

## 起動条件

- `.change-sync.yml` が存在するプロジェクトで作業するとき
- ファイル間の同期ルールを定義・実行するとき
