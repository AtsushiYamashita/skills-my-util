# Skill Quality Guide

公式ベストプラクティスに基づいた、このレポジトリのスキル品質基準。

> Sources:
>
> - [Agent Skills Specification](https://agentskills.io/specification)
> - [Anthropic Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
> - [Gemini CLI Skills](https://geminicli.com/docs/skills)
> - [Official Example Skills](https://github.com/anthropics/skills)

---

## Frontmatter Requirements

```yaml
---
name: skill-name # Required. lowercase, hyphens only. Max 64 chars.
description: | # Required. Max 1024 chars. Third person.
  What this skill does and when to use it.
  Include specific trigger keywords.
license: MIT # Recommended
metadata: # Optional
  author: "author-name"
  version: "1.0"
---
```

### Naming Conventions

- **Gerund form preferred**: `syncing-changes`, `processing-pdfs`
- **Noun phrases acceptable**: `change-sync`, `pdf-processing`
- **Must match directory name**: `skills/change-sync/` → `name: change-sync`
- **Avoid**: `helper`, `utils`, `tools`, `data`, generic terms

### Description Rules

- **Third person only**: "Syncs related files..." (not "I sync" or "You can use")
- **Include what AND when**: What it does + specific activation triggers
- **Specific keywords**: Include terms users would mention

---

## SKILL.md Body

### Token Budget

- **Under 500 lines** for optimal performance
- **Under 5000 tokens** recommended (spec guideline)
- Claude is already smart — only add context it doesn't have

### Content Structure

1. Quick start / Overview (essential, always loaded)
2. Workflow steps (if applicable)
3. References to detailed files (progressive disclosure)

### Progressive Disclosure (3 Layers)

| Layer                                                   | When Loaded         | Token Impact  |
| ------------------------------------------------------- | ------------------- | ------------- |
| Frontmatter (`name`, `description`)                     | Always at startup   | ~100 tokens   |
| SKILL.md body                                           | On skill activation | < 5000 tokens |
| Referenced files (`references/`, `scripts/`, `assets/`) | On demand           | Variable      |

---

## Directory Structure

```
skills/<skill-name>/
├── SKILL.md            # Required. Main instructions
├── scripts/            # Optional. Executable code (not loaded into context)
├── references/         # Optional. Docs loaded on demand
├── assets/             # Optional. Templates, images (not loaded)
└── examples/           # Optional. Usage examples
```

### Path Conventions

- **Always use forward slashes**: `scripts/helper.py` (not `scripts\helper.py`)
- **Relative paths from skill root**: `See [guide](references/GUIDE.md)`

---

## Quality Checklist

Before committing any skill:

### Core Quality

- [ ] `name` field present, lowercase, matches directory name
- [ ] `description` is specific, third-person, includes trigger keywords
- [ ] SKILL.md body under 500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology
- [ ] Concrete examples (not abstract)
- [ ] Progressive disclosure used where appropriate

### Code and Scripts

- [ ] Scripts solve problems (don't punt to the agent)
- [ ] Error handling is explicit and helpful
- [ ] Required packages listed
- [ ] No Windows-style paths
- [ ] Validation/verification steps for critical operations

### Testing

- [ ] Tested with real usage scenarios
- [ ] Edge cases considered

---

## Anti-Patterns

| Anti-Pattern                             | Correct Approach                                             |
| ---------------------------------------- | ------------------------------------------------------------ |
| Vague description: "Helps with files"    | Specific: "Syncs related files when trigger files change..." |
| Over-explaining (teaching Claude basics) | Assume Claude knows; only add unique context                 |
| Too many options without default         | Provide one default, mention alternatives as escape hatch    |
| Windows-style paths `scripts\helper.py`  | Unix-style `scripts/helper.py`                               |
| Deeply nested references (3+ levels)     | Max 1 level deep from SKILL.md                               |
| Monolithic SKILL.md (500+ lines)         | Split into references/ files                                 |
