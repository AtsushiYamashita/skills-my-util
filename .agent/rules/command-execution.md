# Command Execution Rules

## Reliable Methods First

最も信頼性が高く再現可能な方法を最初に提案する。対象 OS、デフォルトシェル、ツールの互換性を考慮。

## Executable Scripts

複数行コマンドはスクリプトファイルとして提供する。各行に**日本語コメント**を付ける。スクリプトが行う永続的変更（ファイル、環境変数、サービス、パッケージ）を明示する。

## Command Proposal

コマンドをユーザーに提案するとき:

- **コマンドの前に**日本語で説明: 何をする、なぜ必要、何が変わる
- **1-2行**で簡潔に — ユーザーはすぐ判断する必要がある

## SafeToAutoRun

| Auto-run ✅ | Require approval ❌ |
| --- | --- |
| `git status`, `git diff`, `git log` | `git push`, `git push --force` |
| `git add` | `git commit` ⚠️ platform enforced |
| `ls`, `cat`, `head`, `tail`, `find`, `grep` | `git reset --hard`, `git rebase` |
| `mkdir`, `New-Item -Directory` | `rm`, `del`, `Move-Item` |
| `npm run lint`, `npm run test` | `npm install`, `pip install` |
| `gh issue list`, `gh pr list` | `npm run build`, `npm run deploy` |
| `Get-Content`, `Test-Path` | `gh issue create`, `gh pr create` |

⚠️ `git commit` は SafeToAutoRun: true でもプラットフォームがブロックする。これは Antigravity の制約であり、ルールでは回避不可。

When in doubt, require approval.
