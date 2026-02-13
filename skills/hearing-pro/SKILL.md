---
name: hearing-pro
description: Facilitates structured dialogue to transform vague ideas into concrete product definitions. Use when the user says things like "I want to make something like…", "I have an idea but it's not clear yet", "Help me figure out what to build", or any request where the goal is ambiguous and needs discovery before design or implementation. Do NOT use when requirements are already clear and the user is ready to build.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Hearing Pro

Transform vague ideas into actionable Product Briefs through structured dialogue.

## Activation

Activate when:

1. The user has an idea but cannot articulate concrete requirements
2. The user explicitly asks for help figuring out what to build
3. The request is ambiguous enough that jumping to implementation would be premature

Do **not** activate when:

- Requirements are already clear → proceed to implementation or `orchestrating-agents`
- The user is asking a question, not proposing to build something
- The user has already completed discovery and wants design/architecture

## Workflow

```
Hearing Flow:
  ┌─ Step 1: Seed ─────────────┐
  │  Capture the initial spark  │
  ├─ Step 2: Expand ────────────┤
  │  Explore dimensions         │
  ├─ Step 3: Crystallize ───────┤
  │  Draft Product Brief        │
  ├─ Step 4: Confirm ───────────┤
  │  Validate and hand off      │
  └─────────────────────────────┘
```

### Step 1: Seed

Capture the user's initial spark without judgment or correction.

- Paraphrase back: "So you want to…?"
- Identify the **core motivation** — what pain or desire drives this idea?
- Do not ask more than **1 clarifying question** here; let the user talk

### Step 2: Expand

Systematically explore dimensions. Ask **2-3 questions per round**, prioritizing what's most unclear.

Question priorities (in order):

1. **Who** — Who will use this? What's their context?
2. **What** — What does success look like? What's the minimum working version?
3. **Why** — Why now? What alternatives have you considered?
4. **Boundary** — What is explicitly _not_ in scope?
5. **Constraints** — Platform, language, timeline, budget, team size?

See [references/question-bank.md](references/question-bank.md) for domain-specific question templates.

**Expand rules:**

- Never ask more than 3 questions at once
- Vary question types (open → closed → provocative)
- If the user gives short answers, offer concrete examples to react to
- If the user gives long answers, summarize and confirm before continuing
- Run **2-4 rounds** of questions; stop when diminishing returns are clear

### Step 3: Crystallize

Synthesize everything into a **Product Brief** draft and present it to the user.

```markdown
# Product Brief: [Working Title]

## Problem
[One paragraph: what pain/desire does this address?]

## Users
[Who are they? What's their context?]

## Core Features (MVP)
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

## Out of Scope
- [Explicitly excluded items]

## Constraints
| Type       | Detail |
| ---------- | ------ |
| Platform   |        |
| Language   |        |
| Timeline   |        |
| Team       |        |

## Open Questions
- [Anything still unresolved]
```

After presenting, ask: "Does this capture what you have in mind? What's missing or wrong?"

### Step 4: Confirm

Finalize the Product Brief based on feedback. Then propose next steps:

- **Ready to build?** → Suggest activating `orchestrating-agents` or direct implementation
- **Need more research?** → Suggest activating `researching-alternatives`
- **Just documenting?** → Save the brief as-is

## Anti-Patterns

- ❌ Proposing solutions during hearing — stay in problem space
- ❌ Asking more than 3 questions at once — overwhelms the user
- ❌ Using technical jargon the user hasn't introduced
- ❌ Skipping straight to architecture or code
- ❌ Accepting "I don't know" without offering concrete alternatives to react to
