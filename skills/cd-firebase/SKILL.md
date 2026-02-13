---
name: cd-firebase
description: Sets up Firebase continuous deployment via GitHub Actions. Covers Hosting (preview channels + live deploy), Functions, Firestore Rules, and authentication (Workload Identity Federation preferred). Use when a project needs automated Firebase deployment.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# CD Firebase

GitHub Actions で Firebase への自動デプロイパイプラインを構築する。

CI（検証）は `ci-setup` スキルが担当。本スキルは **CD（デプロイ）** に集中する。

## Activation

Activate when:

1. Firebase プロジェクトに CD パイプラインがない
2. 手動デプロイ（`firebase deploy`）を自動化したい
3. PR ごとのプレビュー環境が必要

## Workflow

1. **Assess** — Firebase プロジェクト構成を確認
2. **Authenticate** — GitHub Actions ↔ Firebase の認証を設定
3. **Generate** — デプロイワークフローを生成
4. **Verify** — パイプラインの動作を確認

### Step 1: Assess

`firebase.json` を確認し、デプロイ対象を特定する:

| 対象 | 確認方法 | ワークフロー |
| --- | --- | --- |
| Hosting | `firebase.json` に `hosting` キー | PR プレビュー + main マージでライブデプロイ |
| Functions | `firebase.json` に `functions` キー | main マージでデプロイ |
| Firestore Rules | `firestore.rules` の存在 | main マージでデプロイ |
| Storage Rules | `storage.rules` の存在 | main マージでデプロイ |

### Step 2: Authenticate

#### 推奨: Workload Identity Federation（WIF）

長期間有効なサービスアカウントキーを使わず、OIDC で一時的な認証トークンを取得する。

**セットアップ手順:**

```bash
# 1. Workload Identity Pool を作成
gcloud iam workload-identity-pools create "github-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# 2. OIDC Provider を追加
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# 3. サービスアカウントに WIF バインディングを追加
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```

**ワークフローでの使用:**

```yaml
permissions:
  contents: read
  id-token: write

steps:
  - uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: 'projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
      service_account: '${SA_EMAIL}'
```

#### フォールバック: サービスアカウントキー

WIF のセットアップが困難な場合のみ使用する。

```bash
# サービスアカウントキーを生成
gcloud iam service-accounts keys create key.json --iam-account=${SA_EMAIL}

# GitHub Secrets に登録
gh secret set FIREBASE_SERVICE_ACCOUNT < key.json

# ローカルのキーを削除
rm key.json
```

⚠️ **サービスアカウントキーは長期間有効な認証情報。WIF を強く推奨。**

#### IAM ロール（最小権限）

| デプロイ対象 | 必要なロール |
| --- | --- |
| Hosting | `roles/firebasehosting.admin` |
| Functions | `roles/cloudfunctions.admin`, `roles/artifactregistry.writer` |
| Firestore Rules | `roles/firebase.developAdmin` |
| 共通 | `roles/iam.serviceAccountUser` |

### Step 3: Generate

2つのワークフローファイルを生成する:

#### PR プレビュー（Hosting のみ）

```yaml
# .github/workflows/firebase-hosting-preview.yml
name: Firebase Hosting Preview

on:
  pull_request:
    branches: [main]

permissions:
  contents: read
  id-token: write
  pull-requests: write  # PR コメントに URL を書き込む

concurrency:
  group: firebase-preview-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  preview:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run build

      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ vars.WIF_PROVIDER }}
          service_account: ${{ vars.FIREBASE_SA }}

      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ vars.FIREBASE_SA }}
          channelId: 'pr-${{ github.event.pull_request.number }}'
          expires: 14d
```

**Preview Channel のポイント:**

- PR ごとにユニークな URL が生成される
- PR コメントにプレビュー URL が自動投稿される
- `expires` でチャンネルの有効期限を設定（デフォルト 7日）
- PR に新しいコミットが push されるたびに自動更新

#### 本番デプロイ（main マージ時）

```yaml
# .github/workflows/firebase-deploy.yml
name: Firebase Deploy

on:
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write

concurrency:
  group: firebase-deploy-production
  cancel-in-progress: false  # 本番デプロイはキャンセルしない

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # GitHub Environment で保護
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run build

      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ vars.WIF_PROVIDER }}
          service_account: ${{ vars.FIREBASE_SA }}

      - name: Deploy to Firebase
        run: |
          npm install -g firebase-tools
          firebase deploy --project ${{ vars.FIREBASE_PROJECT }}
```

#### Functions のみデプロイ

Functions の変更のみをデプロイする場合、`paths` フィルタを使う:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'functions/**'
      - 'firebase.json'
```

### Step 4: Verify

1. **Preview**: PR を作成し、プレビュー URL が PR コメントに投稿されることを確認
2. **Update**: PR にコミットを追加し、プレビューが更新されることを確認
3. **Deploy**: PR をマージし、本番デプロイが実行されることを確認
4. **Rollback**: 問題があれば `firebase hosting:channel:deploy live --version <previous>` でロールバック

## Security Checklist

```text
□ Workload Identity Federation を使用しているか？（サービスアカウントキーは最終手段）
□ IAM ロールは最小権限か？
□ GitHub Environment で本番デプロイを保護しているか？
□ PR プレビューの expires を設定しているか？
□ firebase.json に機密情報が含まれていないか？
□ .firebaserc をコミットする場合、プロジェクト ID の公開が問題ないか？
```

## Anti-Patterns

- ❌ サービスアカウントキーの JSON をリポジトリにコミット
- ❌ `firebase deploy` を手動で実行し続ける
- ❌ 本番デプロイに `cancel-in-progress: true` を使う（途中キャンセルで中途半端な状態に）
- ❌ IAM ロールに `roles/owner` や　`roles/editor` を使う（最小権限に）
- ❌ Preview Channel に有効期限を設定しない（リソース浪費）
- ❌ CI チェックなしでデプロイする（`ci-setup` で先に検証）
