# AI-Native Repository Structure

AI エージェントを「主役」として配置するリポジトリ構成。

## Directory Template

```
project-root/
├── GEMINI.md                    # AI への憲法（役割・権限・動作定義）
├── ARCHITECTURE.md              # 全体構造 + エントリーポイント
├── core-beliefs.md              # 設計哲学・推論の方向性を規定する信念
│
├── .agent/
│   ├── rules/                   # 常時適用ルール
│   └── workflows/               # 手順定義
│
├── docs/
│   ├── specs/                   # 何を作るか（要求定義）
│   │   └── feature-xxx.md
│   ├── design/                  # どう作るか（設計判断）
│   │   └── DESIGN.md
│   ├── decisions/               # なぜそう作ったか（ADR）
│   │   └── 001-xxx.md
│   └── generated/               # コードから自動生成（人間は触らない）
│       └── db-schema.md
│
├── references/
│   ├── *-llms.txt               # LLM 用高密度リファレンス
│   └── *.md                     # 人間用リファレンス
│
├── exec-plans/
│   ├── active/                  # 実行中タスクの計画ファイル
│   │   └── task-xxx.md
│   └── completed/               # 完了済みの履歴
│       └── task-xxx.md
│
├── QUALITY_SCORE.md             # 品質基準・自己評価ベンチマーク
├── tech-debt-tracker.md         # 未解決課題のバックログ
│
└── src/                         # Feature-based 構成
    ├── domain/
    ├── infra/
    ├── api/
    └── shared/
```

## Knowledge Hierarchy

情報を性質ごとに4層に分ける。AI は上位層で推論の方向を決め、下位層で実装の根拠を得る。

| 層 | ファイル | AI にとっての役割 |
| --- | --- | --- |
| **Philosophical** | `core-beliefs.md`, `DESIGN.md` | 推論の方向性を規定する「信念」 |
| **Intent** | `docs/specs/` | 「何を作るか」— 要求定義 |
| **Blueprints** | `docs/design/`, `ARCHITECTURE.md` | 実装の論理的整合性の担保 |
| **Generated** | `docs/generated/` | コードから自動生成された「真実」。人間は触らない |

## LLM Context Files (`*-llms.txt`)

LLM のコンテキストウィンドウに最適化した高密度リファレンス。

- 散文ではなく**構造化データ**（テーブル、箇条書き、型定義）
- 1ファイル = 1トピック、トークン消費を最小化
- 人間用の README.md とは別に、AI 用の `xxx-llms.txt` を並置する
- 例: `api-llms.txt`（全エンドポイントの型シグネチャ一覧）

## Execution Plans (`exec-plans/`)

タスクの「計画→実行→完了」をファイルで管理する。CozoDB の `tasks` テーブルと併用。

### active/ のファイル構造

```markdown
# Task: <タイトル>

## Goal
<1行で Why>

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Progress
- [x] Step 1 完了 (commit: abc123)
- [ ] Step 2 進行中

## Blockers
なし / <ブロッカーの説明>
```

### ライフサイクル

1. タスク開始 → `exec-plans/active/task-xxx.md` を作成
2. 進捗あり → チェックリストを更新
3. 完了 → `exec-plans/completed/` に移動 + CozoDB に evidence 記録
4. セッション復帰 → `exec-plans/active/` を確認して再開

## Quality Score (`QUALITY_SCORE.md`)

AI の成果物を評価する客観的ベンチマーク。プロジェクトルートに配置。

```markdown
# Quality Score

| Metric | Target | Current | Method |
| --- | --- | --- | --- |
| Test Coverage | >80% | 72% | `npm run test:coverage` |
| Type Safety | 0 `any` | 3 | `grep -r "any" src/` |
| Lint Errors | 0 | 5 | `npm run lint` |
| Open Debt | <10 | 7 | `tech-debt-tracker.md` |
| Doc Coverage | 100% exports | 85% | `typedoc --validation` |
```

## Tech Debt Tracker (`tech-debt-tracker.md`)

未解決の技術的負債を追跡。新規追加時は issue リンク必須。

```markdown
# Tech Debt

| ID | Description | Severity | Issue | Added |
| --- | --- | --- | --- | --- |
| TD-001 | Logger lacks structured output | Medium | #42 | 2024-01-15 |
```

## Context Partitioning

AI がロードする情報量を最小化するための分離原則:

- **Specs** (何を作るか) / **Plans** (どう進めるか) / **Refs** (参照情報) を別ディレクトリに分離
- AI は現在のタスクに必要な層だけロードする
- `exec-plans/active/` の1ファイル → 関連する `docs/specs/` → 必要なら `references/`

## Human Reviews Plans, Not Code

人間のレビュー対象を「コード」から「計画」にシフトする:

- `exec-plans/active/` のタスク計画をレビュー → 方向性の承認
- コードレビューは AI の Phase 3 (Review Board) が担当
- 人間は「What/Why」を判断し、AI は「How」を実行する
