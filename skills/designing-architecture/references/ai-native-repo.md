# AI-Native Repository Structure

AI エージェントがリポジトリを効率的にナビゲートするための構造指針。

## ARCHITECTURE.md

リポジトリのルートに配置する。AI がコードベースの全体像を把握する最初のエントリーポイント。

```markdown
# Architecture

## System Overview
[1段落: このシステムは何をするか]

## Directory Map
src/
├── domain/     # ビジネスロジック（外部依存なし）
├── infra/      # 外部サービスのラッパー
├── api/        # エンドポイント定義
└── shared/     # 横断ユーティリティ

## Key Decisions
- [ADR-001](docs/decisions/001-xxx.md): ...
- [ADR-002](docs/decisions/002-xxx.md): ...

## Entry Points
- メインアプリ: src/index.ts
- テスト: npm run test
- ビルド: npm run build
```

## ディレクトリ構造の規約

| 原則 | 理由 |
| --- | --- |
| **Feature-based** を優先 | AI は「認証機能のコード」と聞いたとき `src/auth/` を探す。`src/controllers/auth.ts` + `src/services/auth.ts` に分散していると探索コストが高い |
| **1ディレクトリ = 1概念** | ディレクトリ名だけで中身が推測できる |
| **index.ts でエクスポート集約** | AI がモジュールの公開 API を1ファイルで把握できる |
| **docs/ に設計判断を蓄積** | `docs/decisions/` (ADR) + `ARCHITECTURE.md` |

## Context Density

AI がコンテキストを効率的に取得するための工夫:

- **README.md** — セットアップ手順 + 簡潔なプロジェクト概要
- **ARCHITECTURE.md** — 全体構造 + エントリーポイント
- **各ディレクトリの README** — 大規模リポでは `src/domain/README.md` で責務を説明
- **型定義ファイルを集約** — `src/types/` or `src/domain/types.ts` に主要な型を集める
- **CLI help / OpenAPI spec** — 実行可能な仕様として参照できる形で保持
