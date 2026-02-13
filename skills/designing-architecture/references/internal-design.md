# Internal Design Principles

プロジェクト内部の構造・レイヤー設計に関する原則。

## Domain-First Design

Before implementation code, define the **domain model**:

- Entities, value objects, aggregates
- Operations they support

This model serves as shared language between code, docs, and user communication. All layers build around this core.

## Onion Architecture (Default)

Structure projects in concentric layers:

```
┌─────────────────────────────────┐
│        Infrastructure           │  I/O, DB, external APIs, frameworks
│  ┌───────────────────────────┐  │
│  │    Application Services   │  │  Use cases, orchestration
│  │  ┌─────────────────────┐  │  │
│  │  │       Domain        │  │  │  Entities, business rules (zero deps)
│  │  └─────────────────────┘  │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

**Rules:**

- Inner layers never depend on outer layers
- Dependency direction always points inward
- Use dependency injection for infrastructure → application

If the workspace defines a different architecture, follow that instead.

## Polymorphism via Interfaces

- Use interfaces (`interface` in TS, `Protocol`/ABC in Python) for contracts between layers
- Enables swapping implementations (real DB vs mock, Node.js vs WASM)
- Prefer **composition over inheritance**
- Enforces dependency inversion principle

## Spike Before Commit

Before integrating any new external service, library, or unfamiliar API:

1. Build a **minimal spike** — isolated proof-of-concept
2. Verify: (a) API behaves as documented, (b) works in target runtime, (c) error handling understood
3. Document spike findings
4. Never commit production code depending on unverified external behaviour
