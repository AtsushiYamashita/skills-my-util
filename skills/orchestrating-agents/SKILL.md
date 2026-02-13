---
name: orchestrating-agents
description: Orchestrates multi-phase task execution using a supervisor/worker pattern with persona switching. The supervisor agent delegates to specialized worker personas (hearing, architect, worker, reviewer) and convenes a multi-expert review board after design. Activates when the user requests building, designing, or implementing something complex that benefits from structured phases and expert review.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Orchestrating Agents

Supervisor pattern: decompose work into phases, switch personas, and run expert reviews before presenting to the user.

## Activation

Activate when:

1. The user requests building or implementing something non-trivial
2. The task spans multiple concerns (requirements, design, implementation, testing)
3. Quality and correctness matter more than speed

Do **not** activate for quick fixes, single-file edits, or questions.

## Pre-flight: Session Sync

Before starting any phase, invoke `task-coordination` Step 4 (Sync):

- Check `gh issue list` for existing in-progress / blocked issues
- If found → resume from last known state instead of starting fresh
- If `blocked:human` issues exist → surface to user immediately

**CozoDB checks:**

- Query `tasks` for `in_progress` → 孤立タスクがあればユーザーに確認
- Query `user_decisions` for past patterns → 類似の質問をする前に過去の判断を参照し、不要な確認を省略する

**Workspace structure check:**

- `ARCHITECTURE.md` が無い → `designing-architecture` を起動提案
- lint / test 設定が無い → `dev-foundation` を起動提案
- 初回セッション（構成未確認）→ 上記を自動チェック

## Workflow

1. Phase 1: Hearing → Requirements gathering
2. **Issue Decomposition** → Create GitHub Issues from Requirements Brief (`task-coordination`)
3. Phase 2: Architecture → Design & planning
4. Phase 3: Review Board → Multi-expert critique
5. Phase 4: Revision → Fix review findings
6. CHECKPOINT: User Approval
7. **Phase 5: Foundation** → Set up shared dev infrastructure (`dev-foundation`)
8. Phase 6: Implementation → Build features
9. Phase 7: Verification → Quality confirmation

At each phase transition, update issue status via `task-coordination`.

### Phase 1: Hearing

**Persona**: [Hearing Agent](references/personas/hearing.md)

Goal: Understand what the user truly needs.

- Clarify the problem, not the solution
- Ask structured questions (who, what, why, constraints)
- Identify acceptance criteria
- **Output**: Requirements Brief (see [handoff-format.md](references/handoff-format.md))
- After output, invoke `task-coordination` Step 1 (Decompose) to create GitHub Issues from the brief

### Phase 2: Architecture

**Persona**: [Architect Agent](references/personas/architect.md)

Goal: Design a solution that solves the root cause.

- Define domain model and boundaries
- Choose tools/patterns (invoke `researching-alternatives` if needed)
- Produce architecture document with diagrams
- **Output**: Design Document

### Phase 3: Review Board

**Personas**: Multiple experts review the design **sequentially**.

See [review-board.md](references/review-board.md) for the full protocol.

Switch persona for each expert, critique the design, collect findings:

| Expert                | Focus                                             |
| --------------------- | ------------------------------------------------- |
| 🔧 Engineering Expert | Feasibility, complexity, maintainability          |
| 🏢 Domain Expert      | Requirements coverage, business logic correctness |
| 🔒 Security Expert    | Threat model, attack surface, data protection     |

- Each expert produces a verdict: ✅ Approve / ⚠️ Approve with conditions / ❌ Reject
- **Output**: Review Board Report (merged findings)

### Phase 4: Revision

**Persona**: [Architect Agent](references/personas/architect.md)

Goal: Address all review findings.

- Fix ❌ Reject items (mandatory)
- Address ⚠️ conditions (mandatory)
- Document accepted trade-offs
- **Output**: Revised Design Document

### CHECKPOINT: User Approval

**Persona**: Supervisor (default)

Present to user:

1. Revised design with rationale
2. Review board summary (what experts said, what was fixed)
3. Remaining trade-offs
4. Ask: "Is this the right direction?"

**Wait for user confirmation before proceeding.**

### Phase 5: Foundation

Goal: Establish shared development infrastructure before feature work.

- Invoke `dev-foundation` (Inventory → Prioritize → Implement → Validate)
- Ensure CI, test harness, linter, and shift-left checks are operational
- **Output**: Working dev environment + CI pipeline

### Phase 6: Implementation

**Persona**: [Worker Agent](references/personas/worker.md)

Goal: Build exactly what was approved.

- Follow the approved design — do not deviate
- Work in small, verifiable increments
- Invoke `enforcing-code-standards` and `checking-cross-platform` as needed
- **Output**: Working code + commit(s) + Draft PR

**Git 運用:**

- `git worktree add` で作業ディレクトリを作成（メインディレクトリは常に main）
- 1 worktree = 1 ブランチ = 1 目的
- 実装完了後は Draft PR を作成 → `git worktree remove` で片付ける

### Phase 7: Verification (Eval)

**Persona**: [Reviewer Agent](references/personas/reviewer.md)

Goal: Prove the implementation satisfies the spec.

- **Spec match** — each acceptance criterion from Phase 1 maps to a passing test or demo
- **Regression** — existing tests still pass
- **Quality gates** — lint, type-check, security scan all green
- **Failure mode analysis** — identify edge cases the implementation doesn't handle, document as known limitations
- **Output**: Verification Report (pass/fail per criterion + known limitations)

## Supervisor Rules

The supervisor (default persona) manages transitions:

1. **Never skip phases** — each phase must produce its output before moving on
2. **Never self-approve** — the review board exists to catch blind spots
3. **Always checkpoint with user** — before implementation begins
4. **Log phase transitions** — record what was decided and why
5. **Update issues on every phase transition** — close completed, move next to in-progress
6. **Sync on session start** — always run pre-flight check before resuming work
