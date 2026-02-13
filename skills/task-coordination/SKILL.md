---
name: task-coordination
description: Manages project tasks using GitHub Issues as a shared coordination layer for multiple agents and humans. Use when starting a new project, kicking off a multi-step task, or when multiple participants (agents or humans) need to collaborate on the same project's work items. Provides workflows for task creation, status tracking, bottleneck detection, and session recovery.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Task Coordination

Coordinate tasks across multiple agents and humans using GitHub Issues as the single source of truth.

## Activation

Activate when:

1. A project has tasks that span multiple sessions or participants
2. Multiple agents or humans need to work on the same project concurrently
3. Resuming work after an interruption (crash, session timeout)

Do **not** activate for:

- Single-session, single-person tasks that finish in one conversation
- Tasks already tracked by another system the user specifies

## Why GitHub Issues

- **No merge conflicts** — unlike file-based TODO, each issue is an independent object
- **Multi-participant** — agents use `gh` CLI, humans use Web UI
- **Notifications** — `blocked:human` label triggers email/Slack alerts
- **Survives crashes** — state lives on GitHub, not in session memory

## Workflow

1. **Decompose** — break work into issues
2. **Label** — mark status and blockers
3. **Execute** — pick an issue, work it, close it
4. **Sync** — check board state on session start

### Step 1: Decompose

At project start, create one issue per deliverable unit:

```
gh issue create --title "<task>" --body "<acceptance criteria>" --label "status:planned"
```

**Rules:**

- One issue = one independently completable unit of work
- Body must include **acceptance criteria** (how to know it's done)
- Add `--milestone "<phase>"` to group related tasks
- Add `--assignee "@me"` when self-assigning

### Step 2: Label

Use a consistent label taxonomy:

| Label | Meaning |
| --- | --- |
| `status:planned` | Not yet started |
| `status:in-progress` | Being worked on |
| `status:blocked` | Waiting on something |
| `blocked:human` | **Human action required** — name who and what in a comment |
| `blocked:external` | Waiting on external dependency |
| `critical-path` | Delay here delays everything |
| `priority:high` | Should be picked up next |

Create labels if they don't exist. See [references/gh-commands.md](references/gh-commands.md) for setup commands.

### Step 3: Execute

When starting work on a task:

1. Assign yourself and set `status:in-progress`
2. Work the task
3. On completion: close the issue with a comment summarizing what was done
4. If blocked: set `status:blocked` + appropriate `blocked:*` label + comment explaining what's needed

```
gh issue edit <number> --add-label "status:in-progress" --remove-label "status:planned"
gh issue close <number> --comment "Done: <summary>"
```

### Step 4: Sync (Session Start)

On every session start, check for existing project state:

```
gh issue list --label "status:in-progress" --json number,title,assignees
gh issue list --label "status:blocked" --json number,title,labels
gh issue list --label "critical-path" --state open --json number,title
```

**If in-progress issues exist with no recent activity** — the previous session likely crashed. Resume from the last known state.

**If blocked:human issues exist** — surface them immediately to the user.

### CozoDB State Layer

GitHub Issues = **計画**（何をやるか）。CozoDB = **実行状態**（実際にどうなったか）。

タスクの状態遷移は CozoDB `tasks` / `task_transitions` に記録する。詳細は `.agent/rules/task-state.md` を参照。

Session Sync 時は GitHub Issues **と** CozoDB 両方を確認する。CozoDB に `in_progress` のまま残っているタスクがあれば、ユーザーにサーフェスする。

## Bottleneck Detection

After Step 1 or when updating tasks, review the dependency chain:

- Identify tasks where **human approval** gates downstream work → label `blocked:human` + `critical-path`
- Suggest **parallel work** — tasks that don't depend on the blocked item
- Ask the user: "These items are waiting on you: [list]. Can you unblock any now?"

## Anti-Patterns

- ❌ Creating issues without acceptance criteria
- ❌ Leaving `status:in-progress` on issues that are actually blocked
- ❌ Not checking existing issues on session start (leads to duplicate work)
- ❌ Mega-issues that cover multiple deliverables
