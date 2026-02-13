---
name: researching-alternatives
description: Researches similar products, tools, and approaches before building something new. Compares alternatives with trade-offs and recommends a default choice. Use when the user wants to build, create, or implement something and the best approach is not yet clear.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Researching Alternatives

Before building, research what exists and compare options to avoid reinventing the wheel.

## Activation

Activate when:

1. The user wants to build, create, or implement something
2. The optimal tool, library, framework, or approach is not obvious
3. No prior research has been done in this conversation

Do **not** activate if the user has already chosen a specific approach and is asking for implementation help.

## Workflow

```
Task Progress:
- [ ] Step 1: Clarify what the user wants to build
- [ ] Step 2: Search for existing solutions and similar products
- [ ] Step 3: Identify candidate approaches (3-5 max)
- [ ] Step 4: Compare with trade-off table
- [ ] Step 5: Recommend a default and get user confirmation
```

**Step 1: Clarify intent**

Before searching, confirm understanding of the user's goal:

- What problem are they solving?
- What constraints exist? (language, platform, budget, team size)
- What quality attributes matter most? (speed, maintainability, security)

**Step 2: Search for existing solutions**

Search for:

- Existing products/services that solve the same problem
- Open-source libraries or frameworks
- Common patterns and architectures used in similar projects
- Blog posts, case studies, or documentation showing real-world usage
- **Agent skill ecosystems**: Run `npx skills find [query]` to search [skills.sh](https://skills.sh/) for existing agent skills that cover the same domain — useful for gap analysis and critical comparison with your own skills

Focus on **proven, maintained** solutions. Check: release recency, community size, known issues.

**Step 3: Identify candidates**

Narrow to 3-5 realistic candidates. For each, note:

- What it is (one sentence)
- Maturity level (production-ready / beta / experimental)
- Adoption signals (GitHub stars, npm downloads, corporate backing)

**Step 4: Compare with trade-off table**

Present using this template:

```markdown
| Criteria        | Option A | Option B | Option C |
| --------------- | -------- | -------- | -------- |
| Maturity        |          |          |          |
| Learning curve  |          |          |          |
| Performance     |          |          |          |
| Maintenance     |          |          |          |
| Community/Docs  |          |          |          |
| Fit for purpose |          |          |          |
```

See [references/comparison-template.md](references/comparison-template.md) for the full template with scoring guide.

**Step 5: Recommend and confirm**

- State a clear **default recommendation** with rationale
- Mention the strongest **alternative** and when to prefer it
- Ask the user: "Is this the right direction?"
- **Wait for confirmation before proceeding to implementation**
