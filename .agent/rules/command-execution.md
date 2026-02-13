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
| `git add`, `git commit` | `git reset --hard`, `git rebase` |
| `ls`, `cat`, `head`, `tail`, `find`, `grep` | `rm`, `del`, `Move-Item` |
| `mkdir`, `New-Item -Directory` | `npm install`, `pip install` |
| `npm run lint`, `npm run test` | `npm run build`, `npm run deploy` |
| `gh issue list`, `gh pr list` | `gh issue create`, `gh pr create` |
| `Get-Content`, `Test-Path` | Any command with `--force` |

When in doubt, require approval.
