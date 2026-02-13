---
name: designing-architecture
description: Guides architecture decisions at two levels — internal project structure (layers, domain model, interfaces) and system boundaries (server/client split, monorepo vs multi-repo, monolith vs microservices). Activates when creating new projects, designing module structure, deciding service boundaries, or making architectural decisions.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "2.0"
---

# Designing Architecture

Architecture decision guide at two levels: project-internal structure and cross-system boundaries.

## Activation

Activate when:

1. `ARCHITECTURE.md` が存在しない、または設計文書が未整備
2. Deciding on project structure or layering
3. Deciding where a feature lives (server/client, which repo, which service)
4. Evaluating monolith vs microservices, monorepo vs multi-repo

Do **not** activate for:

- Implementation details within an already-decided architecture
- Quick fixes or single-file edits

## Decision Router

| Question | Reference |
| --- | --- |
| How to structure layers, domain model, interfaces within a project? | [internal-design.md](references/internal-design.md) |
| Where to draw boundaries between services, repos, server/client? | [system-boundaries.md](references/system-boundaries.md) |
| How to structure a repo so AI agents can navigate efficiently? | [ai-native-repo.md](references/ai-native-repo.md) |

Read the relevant reference based on the user's question. If both apply, start with system boundaries (macro), then internal design (micro).

## Guiding Principles

These apply regardless of scope:

1. **Domain-first** — understand the domain before choosing technology
2. **Keep units small** — each module, service, or component should have a single responsibility describable in one sentence. If it can't be, it's too big
3. **Start simple** — monolith-first, monorepo-first, split later when proven necessary
4. **Spike before commit** — verify assumptions with isolated proof-of-concepts
5. **Explicit trade-offs** — document what you chose and what you gave up
