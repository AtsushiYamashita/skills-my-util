# Rule Format Reference

Full field specification for `.change-sync.yml`.

## Structure

```yaml
version: "1" # Rule format version (required)

rules: # Array of sync rules (required)
  - name: "rule-id" # Unique identifier (required)
    description: "purpose" # Rule purpose (required)
    trigger: # Trigger definition (required)
      path: "file-or-glob" # Watch target path (required)
      watch: ["key1", "key2"] # Narrow watch scope (optional)
    targets: # Sync targets, 1+ (required)
      - path: "target-file" # Target file path (required)
        action: "update" # Action type (required)
        instruction: | # Change instruction (required)
          Specific change description in natural language
```

## Fields

### `trigger.path`

File path or glob pattern, relative to project root.

```yaml
# Single file
path: "package.json"

# Glob pattern
path: "src/db/schemas/*.ts"

# Multiple patterns (array)
path:
  - "src/models/*.ts"
  - "src/entities/*.ts"
```

### `trigger.watch`

Narrows trigger scope. Omit to trigger on any change.

```yaml
# Watch JSON/YAML keys
watch: ["version", "dependencies"]

# Watch code patterns
watch: ["export interface", "export type"]
```

### `targets[].action`

| Action       | If target file missing  |
| ------------ | ----------------------- |
| `update`     | Report error            |
| `regenerate` | Create new file         |
| `flag`       | Report error            |
| `create`     | Create (skip if exists) |

### `targets[].instruction`

Natural language instruction for the agent. Be specific.

**Good:**

```yaml
instruction: |
  Update export const VERSION value to match package.json version.
  Format: export const VERSION = "x.y.z" as const;
```

**Bad:**

```yaml
instruction: "Update the version" # Too vague
```
