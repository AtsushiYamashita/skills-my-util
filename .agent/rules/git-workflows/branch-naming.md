# Branch Naming（ブランチ命名規則）

基本形式: `<type>/<descriptive-name>`
Issue がある場合: `<type>/issue-<N>-<short-desc>`（推奨）

```
feat/issue-19-git-restructure   ← Issue 紐付きの機能開発
fix/typo-readme                 ← Issue なしの軽微な修正
rule/issue-19-git-restructure   ← ルール変更
refactor/extract-helpers        ← リファクタ
```

| type | 用途 | 例 |
| --- | --- | --- |
| `feat` | 新機能の開発 | `feat/issue-19-git-restructure` |
| `fix` | バグ修正 | `fix/resolve-login-error` |
| `docs` | ドキュメント修正 | `docs/update-readme` |
| `refactor` | リファクタ | `refactor/extract-helpers` |
| `rule` | ルール・設定変更 | `rule/atomic-ki` |
| `experiment` | 実験的な変更 | `experiment/try-new-approach` |
