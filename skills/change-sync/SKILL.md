---
description: プロジェクト内の `.change-sync.yml` に定義されたルールに基づき、ファイル変更時に関連ファイルを自動同期する。ユーザーがファイルを変更した際、同期ルールが存在すれば起動する。
---

# Change Sync

プロジェクト内で「A を変更したら B も変更する」依存関係をルールとして宣言し、変更を伝播するスキル。

## Activation

以下の条件がすべて満たされたとき、このスキルを起動する:

1. プロジェクトルートに `.change-sync.yml` が存在する
2. ユーザーがファイルを変更した（または変更について言及した）
3. 変更されたファイルがいずれかのルールの `trigger.path` にマッチする

## Workflow

```
1. .change-sync.yml を読み込む
2. 変更されたファイルを trigger.path と照合する
3. マッチしたルールの targets を順に処理する
4. 各 target の instruction に従って変更を実行する
5. 実行結果をユーザーに報告する
```

### Step 1: ルールの読み込み

プロジェクトルートの `.change-sync.yml` を読み込む。ファイルが存在しない場合、このスキルは何もしない。

### Step 2: トリガー照合

変更されたファイルのパスを各ルールの `trigger.path` と照合する。

- **完全一致**: `package.json` → `package.json` のみ
- **glob パターン**: `src/db/*.ts` → `src/db/` 配下の全 `.ts` ファイル
- **watch フィールドがある場合**: 変更内容が watch に指定されたキー/パターンに関連するか確認する。関連しなければスキップする。

### Step 3: ターゲット処理

マッチしたルールの `targets` を上から順に処理する。各ターゲットについて:

1. `path` で指定されたファイルを確認する
2. `action` に応じた処理を実行する:

| Action       | 処理内容                                                 |
| ------------ | -------------------------------------------------------- |
| `update`     | 対象ファイルの該当箇所のみを部分更新する                 |
| `regenerate` | トリガーファイルの内容に基づいて対象ファイルを再生成する |
| `flag`       | 対象ファイルに要対応マーク（コメント、フラグ）を追加する |
| `create`     | 対象ファイルが存在しない場合のみ、新規作成する           |

3. `instruction` の自然言語指示に従って具体的な変更内容を決定する

### Step 4: 報告

処理完了後、以下をユーザーに報告する:

- 起動されたルール名
- 各ターゲットに対して実行した変更の概要
- 変更できなかった項目がある場合、その理由

## Rule Format Reference

ルールファイル `.change-sync.yml` の全フィールド定義:

```yaml
version: "1" # ルール形式バージョン（必須）

rules: # ルール配列（必須）
  - name: "rule-id" # 一意な識別子（必須）
    description: "説明" # ルールの目的（必須）
    trigger: # トリガー定義（必須）
      path: "file-or-glob" # 監視対象パス（必須）
      watch: ["key1", "key2"] # 監視対象フィールド/パターン（任意）
    targets: # 同期先配列（必須、1つ以上）
      - path: "target-file" # 同期先パス（必須）
        action: "update" # アクション種別（必須）
        instruction: | # 変更指示・自然言語（必須）
          具体的な変更内容をここに記述する
```

### Field Details

#### `trigger.path`

ファイルパスまたは glob パターン。プロジェクトルートからの相対パス。

```yaml
# 単一ファイル
path: "package.json"

# glob パターン
path: "src/db/schemas/*.ts"

# 複数パターン（配列）
path:
  - "src/models/*.ts"
  - "src/entities/*.ts"
```

#### `trigger.watch`

トリガー対象を絞り込む任意フィールド。省略時は全変更がトリガーとなる。

```yaml
# JSON/YAML のキーを監視
watch: ["version", "dependencies"]

# コードの特定パターンを監視
watch: ["export interface", "export type"]
```

#### `targets[].action`

| Value        | 対象ファイルが存在しない場合       |
| ------------ | ---------------------------------- |
| `update`     | エラー報告                         |
| `regenerate` | 新規作成                           |
| `flag`       | エラー報告                         |
| `create`     | 新規作成（存在する場合はスキップ） |

#### `targets[].instruction`

エージェントへの変更指示。自然言語で具体的に記述する。

**良い例:**

```yaml
instruction: |
  export const VERSION の値を package.json の version フィールドの値に合わせて更新する。
  形式: export const VERSION = "x.y.z";
```

**悪い例:**

```yaml
instruction: "バージョンを更新する" # 何をどう更新するか不明
```

## Examples

`examples/` ディレクトリに実用的なルール定義サンプルがあります:

- [version-sync.yml](examples/version-sync.yml) — バージョン番号の一元管理
- [schema-types.yml](examples/schema-types.yml) — DBスキーマ → TypeScript型定義
- [i18n-sync.yml](examples/i18n-sync.yml) — 多言語ファイルの同期管理
