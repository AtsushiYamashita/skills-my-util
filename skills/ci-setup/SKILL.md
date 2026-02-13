---
name: ci-setup
description: Sets up GitHub Actions CI pipelines tailored to the project type. Detects language/framework, selects appropriate checks (lint, test, security, link validation), generates workflow files, and applies monorepo optimizations. Use when a project needs CI or when existing CI needs improvement.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# CI Setup

Set up GitHub Actions CI pipelines tailored to the project's needs.

## Activation

Activate when:

1. プロジェクトに `.github/workflows/` が存在しない
2. 既存の CI がカバー不足（lint なし、テストなし等）
3. `dev-foundation` から CI セットアップを委任された

Do **not** activate for:

- CI が既に十分に機能しているプロジェクト
- GitHub Actions 以外の CI を使うプロジェクト（ユーザーに確認）

## Workflow

1. **Detect** — プロジェクト構成を検出
2. **Select** — 必要なチェックを選択
3. **Generate** — ワークフローファイルを生成
4. **Validate** — パイプラインが動作することを確認

### Step 1: Detect

プロジェクトのルートを調査して以下を特定する:

| 検出対象 | 確認方法 |
| --- | --- |
| 言語/ランタイム | `package.json`(Node), `pyproject.toml`(Python), `go.mod`(Go), `Cargo.toml`(Rust) |
| フレームワーク | 依存関係から判定（Next.js, FastAPI, etc.） |
| モノレポ | 複数の `package.json` / サービスディレクトリの存在 |
| テスト基盤 | `jest.config.*`, `pytest.ini`, `*_test.go` 等 |
| 既存 CI | `.github/workflows/` の有無と内容 |

### Step 2: Select

検出結果に基づいて、適用するチェックを選択する:

| カテゴリ | チェック | 適用条件 |
| --- | --- | --- |
| **Code Quality** | Lint (ESLint/Ruff/golangci-lint) | コードが存在する |
| | Format check (Prettier/Black) | formatter 設定がある |
| | Type check (tsc/mypy/Pyright) | 型定義がある |
| **Test** | Unit test | テストファイルがある |
| | Integration test | テスト + 外部依存がある |
| **Security** | Dependency audit (`npm audit`/`pip-audit`) | 依存パッケージがある |
| | Secret scan | 常時 |
| **Docs** | Markdown lint (`markdownlint-cli`) | `.md` ファイルがある |
| | Link check (`markdown-link-check`) | ドキュメント内リンクがある |
| **Structure** | カスタム検証 | プロジェクト固有のルールがある |

**必須チェック（常に含める）:**

- Secret scan（シークレットの漏洩防止）
- Dependency audit（既知の脆弱性検出）

### Step 3: Generate

`.github/workflows/ci.yml` を生成する。以下の原則に従う:

#### トリガー

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

#### モノレポ最適化

モノレポの場合、`paths` フィルタで変更のあるサービスだけ CI を実行:

```yaml
on:
  push:
    paths:
      - 'services/auth/**'
      - '.github/workflows/ci-auth.yml'
```

#### キャッシュ

依存関係のインストールを高速化する:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
```

| ランタイム | キャッシュ対象 |
| --- | --- |
| Node.js | `node_modules` via `cache: 'npm'` |
| Python | `~/.cache/pip` via `actions/setup-python` + `cache: 'pip'` |
| Go | `~/go/pkg/mod` via `actions/setup-go` + `cache: true` |
| Rust | `~/.cargo` via `actions/cache` |

#### Reusable Workflows

共通のチェックを再利用可能なワークフローに分離:

```yaml
# .github/workflows/reusable-lint.yml
on:
  workflow_call:
    inputs:
      working-directory:
        required: true
        type: string

jobs:
  lint:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
```

呼び出し側:

```yaml
jobs:
  lint:
    uses: ./.github/workflows/reusable-lint.yml
    with:
      working-directory: services/auth
```

### Step 4: Validate

生成したワークフローを検証する:

1. **構文チェック**: `actionlint` でワークフロー YAML を検証
2. **ドライラン**: PR を作成して CI が実行されることを確認
3. **成功確認**: すべてのチェックが green になることを確認
4. **失敗テスト**: 意図的にルール違反して CI が失敗することを確認

```bash
# actionlint のインストールと実行
# https://github.com/rhysd/actionlint
actionlint .github/workflows/*.yml
```

## Best Practices

### ワークフロー設計

| プラクティス | 理由 |
| --- | --- |
| `pull_request` トリガーを必ず含める | マージ前にチェックを通す |
| `paths` フィルタで対象を絞る | 不要な実行を防ぐ |
| キャッシュを積極的に使う | CI 時間を短縮 |
| Reusable Workflow で共通化 | DRY 原則 |
| `concurrency` でキューを制御 | 同一 PR の古い実行をキャンセル |

### Concurrency（同時実行制御）

同じ PR に push が連続した場合、古い実行をキャンセルする:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Security

| プラクティス | 方法 |
| --- | --- |
| シークレットを直書きしない | `${{ secrets.XXX }}` を使う |
| `permissions` を最小限に | `permissions: { contents: read }` |
| Third-party Action をピン留め | `uses: actions/checkout@v4` ではなく SHA でピン留め |
| Dependabot で依存更新 | `.github/dependabot.yml` を設定 |

### Draft PR との連携

エージェントが Draft PR を作成した時、CI が自動実行される。結果を PR コメントに記録する:

```bash
gh pr checks <number> --watch
```

## Anti-Patterns

- ❌ CI なしでマージを許可する
- ❌ すべての変更でフルビルドを実行（モノレポ）
- ❌ キャッシュなしで毎回依存をインストール
- ❌ セキュリティチェックを後回しにする（shift-left で初日から）
- ❌ ワークフローファイルに直接シークレットを書く
- ❌ Third-party Action をバージョン指定なしで使う
