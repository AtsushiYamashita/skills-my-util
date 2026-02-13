---
name: change-sync
description: Propagates file changes across a project based on declarative rules defined in .change-sync.yml. Syncs related files automatically when trigger files are modified. Use when a project contains a .change-sync.yml file and the user modifies a file that matches a sync rule trigger.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Change Sync

Propagates file changes based on declarative sync rules in `.change-sync.yml`.

## Activation

Activate when all conditions are met:

1. `.change-sync.yml` exists at the project root
2. A file matching a `trigger.path` was changed
3. If `trigger.watch` is set, the change touches a watched key/pattern

## Workflow

```
Task Progress:
- [ ] Step 1: Load .change-sync.yml
- [ ] Step 2: Match changed file to trigger.path
- [ ] Step 3: Process each target per instruction
- [ ] Step 4: Report results to user
```

**Step 1**: Read `.change-sync.yml` from project root. If absent, stop.

**Step 2**: Match the changed file path against each rule's `trigger.path` (exact match or glob). If `trigger.watch` is set, verify the change touches a watched key/pattern. Skip if unrelated.

**Step 3**: For each matched rule, process `targets` in order:

| Action       | Behavior                               |
| ------------ | -------------------------------------- |
| `update`     | Partially update the target file       |
| `regenerate` | Recreate target from trigger content   |
| `flag`       | Add a TODO/review marker to the target |
| `create`     | Create target only if it doesn't exist |

Follow each target's `instruction` field for specific changes.

**Step 4**: Report to user: which rules fired, what changed, and any failures.

## Rule Format

See [references/rule-format.md](references/rule-format.md) for the full field specification.

Quick example:

```yaml
version: "1"
rules:
  - name: "version-sync"
    description: "Sync package.json version to source"
    trigger:
      path: "package.json"
      watch: ["version"]
    targets:
      - path: "src/version.ts"
        action: "update"
        instruction: |
          Update export const VERSION to match package.json version.
```

## Examples

See [examples/](examples/) for complete rule definitions:

- [version-sync.yml](examples/version-sync.yml) — Version number sync
- [schema-types.yml](examples/schema-types.yml) — DB schema → TypeScript types
- [i18n-sync.yml](examples/i18n-sync.yml) — Multi-language file sync
