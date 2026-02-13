---
name: enforcing-code-standards
description: Enforces production-grade code quality standards including structured logging, documentation comments, type safety, functional style, separation of concerns, and conventional commits. Activates when writing, reviewing, or refactoring code in any language.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
  origin: "Extracted from GEMINI.md Principle V-A, V-B (§1-13)"
---

# Enforcing Code Standards

Production-grade code quality rules for all languages and projects.

## Activation

Activate when:

1. Writing new code (any language)
2. Reviewing or refactoring existing code
3. Setting up project tooling (linters, formatters, CI)
4. Providing code in documentation or examples

## Code Quality Checklist

Apply these rules to all code:

### Production-Grade

Design metrics, security, and observability from the start:

- Input validation and sanitisation
- Error handling that never leaks internals
- Performance-measurable instrumentation points
- Principle of least privilege

### Separation of Concerns

- **Pure vs impure**: Separate deterministic functions from I/O/state mutation
- **Domain vs generic**: Separate business logic from data transformation utilities

関数はテスト容易性で切り分ける：

| 分類 | 特徴 | テスト方法 |
| --- | --- | --- |
| **Pure（副作用なし）** | 入力→出力のみ、外部依存なし | 直接テスト可能 |
| **Impure（副作用あり）** | ファイル I/O、API 呼び出し、状態変更 | 依存をインジェクションしてテスト |

設計原則：

- ロジックは Pure 関数に寄せる（テストしやすい）
- I/O は薄い Impure ラッパーに閉じ込める
- Impure 関数は依存（ファイルシステム、HTTP クライアント等）を引数で受け取る

### External Dependency Wrapping

Never call external services, APIs, or CLI tools directly from feature code:

- **Wrap** — create an adapter with a clean interface that hides the external API
- **Test** — unit test the wrapper with mocked external calls
- **Depend on the interface** — feature code imports the wrapper, never the raw SDK/client

This enables: swapping implementations, testing in isolation, and containing blast radius when external APIs change.

### Documentation Comments

All exported items must include standard doc comments (JSDoc, docstrings, etc.):

- Purpose, parameters with types, return value, thrown errors
- Usage examples where non-obvious

### Diagrams in Docs

Choose format by audience and diagram type:

| Audience | Diagram type | Format |
| --- | --- | --- |
| Human (README, design docs, ADRs) | All | **Mermaid** |
| Agent (SKILL.md) | Dependencies / graphs | Graph DB query (Datalog) |
| Agent (SKILL.md) | Steps / flows | Numbered list |
| Agent (SKILL.md) | Comparisons | Table |
| Agent (SKILL.md) | Hierarchies | Indented list |

### Structured Logging

See [references/logging-standards.md](references/logging-standards.md) for the full specification.

Quick rules:

- Levels: `FATAL` / `ERROR` / `WARN` / `INFO` / `DEBUG`
- Required fields: ISO 8601 timestamp, level, module, message
- Never log secrets, PII, or raw sensitive data
- Every `ERROR` must answer: what failed, why, what input caused it

### TypeScript Type Safety

- Never use `any` — use `unknown` with explicit narrowing
- Minimise `as Type` assertions
- Prefer interfaces over classes for data structures

### Functional & Immutable-First

- Prefer `.map()`, `.filter()`, `.reduce()` over `for` loops
- Never mutate arguments or shared state
- Prefer plain objects with interfaces over classes
- Use `export`/non-export for public/private boundaries

### Nesting Budget（スコープ行数制限）

ネストが深いコードは読めない。以下の行数制限を超えたら関数に切り出す：

| スコープ深度 | 最大行数 | 例 |
| --- | --- | --- |
| 第1（関数トップレベル） | **30行** | `function doSomething() { ... }` |
| 第2（if / for / try 内） | **15行** | `if (cond) { ... }` |
| 第3（ネストの中のネスト） | **3行** | `if (a) { if (b) { /* 3行まで */ } }` |
| 第4以上 | **禁止** | → 説明関数に切り出す |

対策の優先順位：

1. **早期リターン** — `if (!cond) return` でネストを減らす
2. **説明変数** — 条件式に名前をつけて可読性を上げる
3. **説明関数** — ブロックの中身を関数に抽出する
4. **switch** — elseif チェーンは説明変数 + switch に変換

条件式の複雑度：`&&` / `||` が **3つ以上** 連なったら説明変数に切り出す。

```typescript
// ❌ Bad
if (user.isActive && user.role === 'admin' && !user.isBanned && org.plan === 'pro') { ... }

// ✅ Good
const isAuthorizedAdmin = user.isActive && user.role === 'admin' && !user.isBanned;
const isProOrg = org.plan === 'pro';
if (isAuthorizedAdmin && isProOrg) { ... }
```

### High-Value Comments Only

Comment only _why_, not _what_. No conversational comments. No TODO without issue reference.

### Technology Decision Records

Document tool/library/framework choices in `docs/decisions/` using ADR format:

- Topic, alternatives with pros/cons, chosen option, rationale, trade-offs

### AI-Native Code Structure

AI（エージェント含む）が読み書きしやすいコードを書く:

- **高モジュール化** — 1ファイル1責務。300行を超えたら分割を検討
- **明示的な型** — 暗黙の型推論より明示的な型定義を優先
- **自己文書化** — 関数名・変数名で意図が伝わる命名。略語を避ける
- **Contract-first** — インターフェース/型定義を先に書き、実装は後
- **テストが仕様** — テストコードが正式な仕様書として機能するレベルに
