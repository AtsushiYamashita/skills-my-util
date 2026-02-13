---
name: reviewing-safety
description: Reviews code for security vulnerabilities, environmental safety, blast radius, and test coverage. Applies defense-in-depth principles and test pyramid strategy. Activates when writing scripts, reviewing security, designing tests, or modifying shared modules.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
  origin: "Extracted from GEMINI.md Principle V-D, V-E (§18-21)"
---

# Reviewing Safety

Security, environmental safety, and testing standards.

## Activation

Activate when:

1. Writing or reviewing shell scripts
2. Modifying security-sensitive code (auth, input handling, API boundaries)
3. Designing or reviewing test strategy
4. Changing shared modules with downstream consumers

## Environment-Safe Scripting

Scripts must not pollute the user's environment:

- **No global state mutation**: Avoid modifying PATH, global packages, system-wide config unless explicitly requested
- **Local-first**: Prefer `npx`, `--save-dev`, virtual environments
- **Idempotent**: Running twice must not produce errors or duplicate changes
- **Document side-effects**: If global changes are unavoidable, document every side-effect and provide rollback procedure

## Blast Radius Minimisation

Every code change must limit its impact scope:

- Prefer narrow, targeted edits over sweeping refactors
- Assess and document downstream consumers when modifying shared modules
- Use feature flags or abstraction boundaries when impact is uncertain
- Isolate risky changes into separate modules or commits with explicit scope annotation

## Defense in Depth

Never rely on a single layer of defense:

| Layer           | Controls                                |
| --------------- | --------------------------------------- |
| API boundary    | Input validation, rate limiting         |
| Domain logic    | Business rule validation, authorization |
| Gateway/service | Authentication + authorization checks   |
| Output          | Encoding, Content Security Policies     |

**Assume every layer can be bypassed** — each must independently prevent exploitation.

Treat all external input as untrusted:

- User data
- API responses
- File contents
- Environment variables

## Test Strategy

### Test Pyramid

```
    ╱  E2E  ╲         Few, slow, comprehensive
   ╱ Integration ╲     Medium count, real dependencies
  ╱   Unit Tests   ╲   Many, fast, isolated
```

### Rules

- **Unit tests**: Deterministic, isolated (no network/filesystem/DB), fast
- **Mocks/stubs**: Only at layer boundaries — not to paper over tight coupling
- **Difficult to test = design problem**: Refactor the code, don't skip the test
- **Every functional change must include tests**
