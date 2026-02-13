# skills-my-util

AI エージェント用のスキル・ルール・ワークフローを一元管理するモノレポジトリ。

## アーキテクチャ

```mermaid
flowchart TB
    subgraph Always["常時適用 (.agent/rules/)"]
        R1[command-execution]
        R2[conventions]
        R3[core-principles]
        R4[goal-alignment]
        R5[reasoning-first]
        R6[task-state<br/>+ CozoDB]
        R7[task-planning]
        R8[self-correction]
    end

    subgraph Session["セッション境界"]
        SE["/session-end"]
    end

    subgraph Preflight["Pre-flight: Session Sync"]
        PF1["gh issue list<br/>(in-progress/blocked)"]
        PF2["CozoDB tasks<br/>(orphan detection)"]
        PF3["user_decisions<br/>(prediction load)"]
        PF4["Workspace check<br/>(ARCHITECTURE.md?)"]
    end

    subgraph Skills["条件付き活性化 (skills/)"]
        direction LR
        S1[orchestrating-agents<br/>非自明タスク]
        S2[hearing-pro<br/>要件不明確]
        S3[designing-architecture<br/>設計文書未整備]
        S4[dev-foundation<br/>基盤未構築]
        S5[enforcing-code-standards<br/>コード作成/レビュー]
        S6[reviewing-safety<br/>セキュリティ]
        S7[researching-alternatives<br/>技術選定]
        S8[task-coordination<br/>複数参画者]
        S9[debugging-systematic<br/>バグ調査]
        S10[checking-cross-platform<br/>互換性]
        S11[change-sync<br/>ファイル同期]
    end

    Start([セッション開始]) --> Preflight
    Preflight --> |構造欠落| S3 & S4
    Preflight --> |孤立タスク| S8
    Preflight --> |問題なし| Work([作業開始])
    Work --> |非自明| S1
    Work --> |軽微| R1
    S1 --> |Phase 1| S2
    S1 --> |Phase 2| S3
    S1 --> |Phase 5| S5
    S1 --> |Phase 7| S6
    Work --> |セッション終了| SE
```

## 起動フロー

```mermaid
sequenceDiagram
    participant U as User
    participant A as Agent (Supervisor)
    participant C as CozoDB
    participant G as GitHub Issues

    Note over A: Session Start
    A->>C: tasks WHERE status='in_progress'?
    C-->>A: orphaned tasks (if any)
    A->>C: user_decisions (load patterns)
    A->>A: Check ARCHITECTURE.md exists?
    A->>G: gh issue list --label in-progress

    alt 孤立タスクあり
        A->>U: 「前回のタスクが残っています」
    end

    Note over A: 作業フェーズ
    A->>C: PUT tasks [id, "in_progress"]
    A->>C: PUT task_transitions
    A->>A: 判断が必要？→ user_decisions で予測
    alt パターンあり
        A->>A: 予測して実行
        A->>U: 「過去の判断に基づき X しました」
    else パターンなし
        A->>U: 確認
        U->>A: 回答
        A->>C: PUT user_decisions
    end

    Note over A: タスク完了
    A->>C: PUT tasks [id, "done", evidence]
    A->>C: PUT task_transitions
    A->>G: gh issue close --comment
```

## セットアップ

```powershell
# 全スキルを Antigravity にインストール
.\scripts\setup.ps1 -t antigravity

# ルール/ワークフローを全ワークスペースに配布
.\scripts\sync-env.ps1

# 特定プロジェクトにも配布
.\scripts\sync-env.ps1 -TargetWorkspace "D:\project\my-app"
```

> [!NOTE]
> `setup.ps1` はシンボリックリンクを使用するため、リポジトリ内の編集が即座に反映されます。
> Windows では管理者権限 or 開発者モードが必要です。

### 対応プラットフォーム

| Target        | Skill Path                                   |
| ------------- | -------------------------------------------- |
| `claude-code` | `~/.claude/skills/<skill-name>/`             |
| `gemini-cli`  | `~/.gemini/skills/<skill-name>/`             |
| `antigravity` | `~/.gemini/antigravity/skills/<skill-name>/` |

## コンポーネント一覧

### Skills（条件付き活性化）

| スキル | 概要 | 起動条件 |
| --- | --- | --- |
| [orchestrating-agents](skills/orchestrating-agents/) | 7フェーズ委任 + Pre-flight Sync | 非自明タスク |
| [hearing-pro](skills/hearing-pro/) | アイデア具体化、既存サービスチェック | 要件不明確 |
| [designing-architecture](skills/designing-architecture/) | ドメイン駆動 + AI-Native リポ構造 | `ARCHITECTURE.md` 未整備 |
| [dev-foundation](skills/dev-foundation/) | Shift-left、CI/CD、依存ラッピング | 基盤未構築 |
| [enforcing-code-standards](skills/enforcing-code-standards/) | コード品質、AI-Native 構造 | コード作成/レビュー |
| [reviewing-safety](skills/reviewing-safety/) | 爆発半径、多層防御、テスト | セキュリティレビュー |
| [researching-alternatives](skills/researching-alternatives/) | 調査比較 + ADR 出力 | 技術選定 |
| [task-coordination](skills/task-coordination/) | GitHub Issues + CozoDB 二層管理 | 複数参画者 |
| [debugging-systematic](skills/debugging-systematic/) | 仮説駆動6ステップ | バグ調査 |
| [checking-cross-platform](skills/checking-cross-platform/) | OS/シェル互換性 | スクリプト/CI |
| [change-sync](skills/change-sync/) | 宣言的ファイル変更伝播 | ファイル同期 |

### Rules（常時適用）

| ルール | 内容 |
| --- | --- |
| [command-execution](/.agent/rules/command-execution.md) | SafeToAutoRun 分類、日本語コマンド提案 |
| [conventions](/.agent/rules/conventions.md) | Conventional Commits、コンテキスト保存 |
| [core-principles](/.agent/rules/core-principles.md) | 4原則（User-Centricity 等） |
| [goal-alignment](/.agent/rules/goal-alignment.md) | Goal/Action 明示、Why 問い返し |
| [reasoning-first](/.agent/rules/reasoning-first.md) | 思考→計画→実行→検証 |
| [task-state](/.agent/rules/task-state.md) | CozoDB タスク追跡 + 判断予測 |
| [task-planning](/.agent/rules/task-planning.md) | Gantt chart、セッション復帰 |
| [self-correction](/.agent/rules/self-correction.md) | エラー報告レベル |

### Workflows（明示的呼び出し）

| ワークフロー | 内容 |
| --- | --- |
| `/session-end` | セッション終了時のコンテキスト永続化 |
| `/new-skill` | 新規スキル作成 |

### CozoDB テーブル

| テーブル | 用途 |
| --- | --- |
| `tasks` | タスク状態管理（evidence 必須 done） |
| `task_transitions` | 遷移の監査証跡 |
| `user_decisions` | ユーザー判断パターン → 予測 |

## ディレクトリ構造

```
skills-my-util/
├── GEMINI.md               # Agent の憲法（目次のみ、39行）
├── .agent/
│   ├── rules/              # 常時適用ルール（12個）
│   └── workflows/          # 手順定義（2個）
├── skills/                 # 条件付きスキル（11個）
│   └── <skill-name>/
│       ├── SKILL.md        # スキル定義（必須）
│       └── references/     # 詳細仕様（任意）
├── scripts/
│   ├── setup.ps1           # マルチプラットフォーム セットアップ
│   ├── sync-env.ps1        # ルール/ワークフロー配布
│   └── new-skill.ps1       # スキル雛形生成
├── docs/
│   ├── skill-quality-guide.md
│   └── references.md
└── MEMORY/                 # セッションログ
```

## 新しいスキルの作成

```powershell
.\scripts\new-skill.ps1 -SkillName "my-new-skill"
```

または、エージェントから `/new-skill` ワークフローを使用してください。

## ライセンス

[MIT](LICENSE)
