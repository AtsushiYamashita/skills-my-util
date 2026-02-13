# gh CLI Quick Reference

Task coordination で使用する `gh` コマンドのリファレンス。

## Initial Setup

プロジェクトに必要なラベルを一括作成:

```powershell
$labels = @(
    @{ name = "status:planned";     color = "c5def5"; description = "Not yet started" }
    @{ name = "status:in-progress"; color = "0e8a16"; description = "Being worked on" }
    @{ name = "status:blocked";     color = "d93f0b"; description = "Waiting on something" }
    @{ name = "blocked:human";      color = "e4e669"; description = "Human action required" }
    @{ name = "blocked:external";   color = "fbca04"; description = "Waiting on external dependency" }
    @{ name = "critical-path";      color = "b60205"; description = "Delay here delays everything" }
    @{ name = "priority:high";      color = "d93f0b"; description = "Should be picked up next" }
)

foreach ($l in $labels) {
    gh label create $l.name --color $l.color --description $l.description --force
}
```

## Common Operations

### Create issue

```bash
gh issue create --title "Implement auth" --body "AC: login/logout works" --label "status:planned"
```

### Start work

```bash
gh issue edit 42 --add-label "status:in-progress" --remove-label "status:planned"
```

### Mark blocked

```bash
gh issue edit 42 --add-label "status:blocked,blocked:human" --remove-label "status:in-progress"
gh issue comment 42 --body "Blocked: waiting for @user to approve design doc"
```

### Complete

```bash
gh issue close 42 --comment "Done: implemented auth with Firebase"
```

### Session start sync

```bash
gh issue list --label "status:in-progress" --json number,title,assignees
gh issue list --label "status:blocked" --json number,title,labels
gh issue list --label "critical-path" --state open --json number,title
gh issue list --state open --json number,title,labels --limit 50
```
