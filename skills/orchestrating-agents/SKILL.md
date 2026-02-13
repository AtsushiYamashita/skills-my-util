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

## Workflow

1. Phase 1: Hearing → Requirements gathering
2. **Issue Decomposition** → Create GitHub Issues from Requirements Brief (`task-coordination`)
3. Phase 2: Architecture → Design & planning
4. Phase 3: Review Board → Multi-expert critique
5. Phase 4: Revision → Fix review findings
6. CHECKPOINT: User Approval
7. Phase 5: Implementation → Build it
8. Phase 6: Verification → Quality confirmation

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

### Phase 5: Implementation

**Persona**: [Worker Agent](references/personas/worker.md)

Goal: Build exactly what was approved.

- Follow the approved design — do not deviate
- Work in small, verifiable increments
- Invoke `enforcing-code-standards` and `checking-cross-platform` as needed
- **Output**: Working code + commit(s)

### Phase 6: Verification

**Persona**: [Reviewer Agent](references/personas/reviewer.md)

Goal: Confirm the implementation matches the design.

- Verify acceptance criteria from Phase 1
- Run quality gate checks
- Invoke `reviewing-safety` for security-sensitive code
- **Output**: Verification Report

## Supervisor Rules

The supervisor (default persona) manages transitions:

1. **Never skip phases** — each phase must produce its output before moving on
2. **Never self-approve** — the review board exists to catch blind spots
3. **Always checkpoint with user** — before implementation begins
4. **Log phase transitions** — record what was decided and why
5. **Update issues on every phase transition** — close completed, move next to in-progress
6. **Sync on session start** — always run pre-flight check before resuming work
