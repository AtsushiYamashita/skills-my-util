# System Boundaries

サービス間・リポジトリ間の境界をどこに引くかの判断フレームワーク。

## Server vs Client

機能をサーバー側とクライアント側のどちらに置くかの判断基準。

| Factor | Server 寄り | Client 寄り |
| --- | --- | --- |
| **Data sensitivity** | 機密データ処理、認証/認可 | 表示専用、ユーザー入力バリデーション |
| **Computation** | 重い計算、バッチ処理 | UIアニメーション、ローカルフィルタリング |
| **Consistency** | 複数クライアント間の一貫性が必要 | オフライン動作が必要 |
| **Latency** | 一括取得で往復を減らせる | 即時レスポンスが必要 |
| **Coupling** | ビジネスルールの変更頻度が高い | プラットフォーム固有のUX最適化 |

**Decision flow:**

1. セキュリティ要件 → 機密処理は必ずサーバー
2. 一貫性要件 → 複数クライアントが同じ状態を見る必要があるならサーバー
3. レスポンス要件 → 即時応答が必要ならクライアント（楽観的更新 + サーバー同期）
4. 変更頻度 → ビジネスロジックが頻繁に変わるならサーバー（デプロイ独立性）

## Monorepo vs Multi-repo

リポジトリの分割判断。

| Factor | Monorepo 寄り | Multi-repo 寄り |
| --- | --- | --- |
| **Team size** | 小チーム（1-3人） | 複数チーム、独立リリースサイクル |
| **Shared code** | 共通ライブラリが多い | 共通部分が少なく、API契約で十分 |
| **Deploy cadence** | 全体を同時デプロイ | サービスごとに異なるリリース |
| **CI/CD complexity** | ビルドツールがmonorepo対応 | 各リポが独立パイプライン |
| **Code ownership** | チーム全員がコード全体を把握 | 明確なオーナーシップ境界が必要 |

**Default recommendation:** 迷ったら **monorepo から始める**。分割は後からできるが、統合は難しい。

## Monolith vs Microservices

サービスアーキテクチャの選択。

| Factor | Monolith 寄り | Microservices 寄り |
| --- | --- | --- |
| **Project stage** | MVP、新規プロダクト | 成熟したプロダクト、スケール要件 |
| **Team** | 小チーム、フルスタック | 大チーム、ドメイン別チーム |
| **Deployment** | シンプルなデプロイで十分 | サービス毎に異なるスケール要件 |
| **Data** | 単一DB、トランザクション | サービス毎にDB、結果整合性OK |
| **Complexity budget** | 運用コスト最小化 | 分散システムの運用能力がある |

**Default recommendation:** **Monolith-first**。Martin Fowler の "MonolithFirst" 原則に従い、ドメイン境界が明確になってから分割する。

## Module Extraction Checklist

既存コードから独立モジュール/サービスに切り出す判断：

1. **独立してデプロイする必要があるか？** → No なら同一リポのパッケージで十分
2. **異なる技術スタックが必要か？** → No なら同一言語のモジュール分割で十分
3. **異なるスケール特性があるか？** → No ならモノリス内でスケール
4. **チームの所有権を分離したいか？** → No なら CODEOWNERS で十分
5. **障害隔離が必要か？** → No ならプロセス内エラーハンドリングで十分

**All Yes → サービスとして切り出す妥当性あり**
**1-2 Yes → pakage/module レベルの分離を検討**
**All No → そのまま**

## Anti-Patterns

- ❌ **Premature decomposition** — ドメイン理解が浅い段階でマイクロサービス化
- ❌ **Distributed monolith** — サービスを分けたが密結合のまま（最悪のパターン）
- ❌ **Shared database** — サービス間でDBを直接共有
- ❌ **Sync chain** — A → B → C → D の同期呼び出しチェーン
- ❌ **Repo per file** — 不必要に細かいリポジトリ分割
