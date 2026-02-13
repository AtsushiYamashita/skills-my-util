---
name: dev-foundation
description: Sets up shared development infrastructure before feature implementation begins. Covers shared libraries, CI/CD pipelines, test harnesses, dev environment standardization, and shift-left practices (security scanning, static analysis, dependency checks from day one). Use when starting a new project, onboarding a new codebase, or when the team discovers missing foundational tooling mid-project.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Dev Foundation

Establish shared development infrastructure before writing feature code.

## Activation

Activate when:

1. Starting a new project after architecture design is approved
2. Onboarding an existing codebase that lacks standardized tooling
3. Adding a new service/repo to an existing system

Do **not** activate for:

- Projects with established foundations that only need feature work
- Quick prototypes or spikes (by definition, foundations are overkill)

## Workflow

1. **Inventory** — what shared infrastructure is needed?
2. **Prioritize** — what blocks feature work? Build that first
3. **Implement** — set up foundations
4. **Validate** — verify the foundation works end-to-end

### Step 1: Inventory

Audit the project against these categories:

| Category | Items to check |
| --- | --- |
| **Shared code** | Common types, utility libraries, API contracts (OpenAPI, gRPC proto) |
| **CI/CD** | Build pipeline, branch strategy, deploy automation, artifact storage |
| **Test infra** | Test runner, fixture patterns, mock/stub strategy, E2E environment |
| **Dev environment** | Dev container / devbox, linter + formatter config, editor settings |
| **Observability** | Logging framework, error tracking, metrics/tracing setup |
| **Shift-left** | See [references/shift-left-checklist.md](references/shift-left-checklist.md) |

Output: a checklist of what exists vs. what's missing.

### Step 2: Prioritize

Order by **what blocks feature work**:

1. **Build & run** — can developers build and run the project locally?
2. **Test** — can developers write and run tests?
3. **Deploy** — can code reach a staging/production environment?
4. **Quality gates** — are checks automated (lint, type-check, security scan)?

If something in category 1 is missing, stop and fix it before anything else.

### Step 3: Implement

Build foundations in priority order. For each item:

- Invoke `enforcing-code-standards` for coding conventions
- Invoke `reviewing-safety` for security-related foundations
- Invoke `designing-architecture` for structural decisions

### Step 4: Validate

Before declaring the foundation complete:

- [ ] A new developer can clone, build, and run tests in under 10 minutes
- [ ] CI pipeline passes on a clean commit
- [ ] Shift-left checks run automatically (not manually)
- [ ] Shared libraries are importable from feature code

## Anti-Patterns

- ❌ Building features on a broken foundation ("we'll fix CI later")
- ❌ Over-engineering foundations before requirements are clear
- ❌ Copy-pasting config between repos instead of sharing
- ❌ Manual quality checks that should be automated
