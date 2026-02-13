# Handoff Format

Standard document formats for phase transitions. Each phase produces a specific output that becomes the input for the next phase.

## Phase 1 → 2: Requirements Brief

```markdown
# Requirements Brief

## Problem Statement

[One paragraph describing the problem]

## Acceptance Criteria

- [ ] Criterion 1 (measurable, verifiable)
- [ ] Criterion 2
- [ ] Criterion 3

## Constraints

| Type         | Constraint |
| ------------ | ---------- |
| Platform     |            |
| Language     |            |
| Timeline     |            |
| Dependencies |            |
| Budget       |            |

## Quality Priorities (ordered)

1. [e.g., Security > Maintainability > Performance]

## Out of Scope

- [Explicitly excluded items]
```

## Phase 2 → 3: Design Document

```markdown
# Design Document

## Overview

[Summary of the approach]

## Domain Model

[Entities, relationships, key operations — use mermaid diagram]

## Architecture

[Layers, components, data flow — use mermaid diagram]

## Technology Choices

| Component | Choice | Rationale |
| --------- | ------ | --------- |
|           |        |           |

## API / Interface Design

[Key interfaces and contracts]

## Error Handling Strategy

[How errors propagate and are handled]

## Security Considerations

[Threats identified and mitigations]

## Open Questions

[Unresolved decisions, if any]
```

## Phase 3 → 4: Review Board Report

```markdown
# Review Board Report

## Summary

| Expert         | Verdict  |
| -------------- | -------- |
| 🔧 Engineering | ✅/⚠️/❌ |
| 🏢 Domain      | ✅/⚠️/❌ |
| 🔒 Security    | ✅/⚠️/❌ |

## Critical Findings (must fix)

1. [Finding + recommendation]

## Conditions (must resolve)

1. [Condition + resolution path]

## Notes (informational)

1. [Observation]
```

## Phase 6: Verification Report

```markdown
# Verification Report

## Acceptance Criteria Status

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
|           | ✅/❌  |          |

## Issues Found

| #   | Severity | Description | Resolution |
| --- | -------- | ----------- | ---------- |
|     |          |             |            |

## Overall Verdict

✅ Pass / ⚠️ Pass with notes / ❌ Fail
```
