# Structured Logging Standards

Full specification for structured logging across all code.

## Log Levels

| Level   | When to use                                                           |
| ------- | --------------------------------------------------------------------- |
| `FATAL` | Process must exit                                                     |
| `ERROR` | Operation failed, needs intervention                                  |
| `WARN`  | Degraded but recoverable                                              |
| `INFO`  | Lifecycle events: startup, shutdown, config loaded, request completed |
| `DEBUG` | Internal state useful during development                              |

## Required Context Fields

Every log entry must include:

- ISO 8601 timestamp
- Log level
- Module/function name
- Human-readable message
- Correlation/request ID (for request-scoped operations)
- Tenant ID (for multi-tenant systems)

## What to Log

Log at every **boundary**:

- Function entry/exit for critical paths
- External API calls (request + response status + elapsed time)
- State transitions
- Retry attempts
- Cache hits/misses
- All caught exceptions with stack traces

## What NOT to Log

- Secrets, passwords, tokens
- PII (personally identifiable information)
- Raw request/response bodies containing sensitive data
- Mask or redact when context is needed

## Error Log Requirements

Every `ERROR` log must answer:

1. **What** failed
2. **Why** (root cause or error code)
3. **What input/state** led to it

❌ `logger.error("An error occurred")`
✅ `logger.error({ err, userId, action: "payment" }, "Payment failed: card declined")`

## Format

Use JSON or key-value structured format (not string concatenation).

Preferred libraries:

- **Node.js**: `pino` or `winston`
- **Python**: `logging` (stdlib) with JSON formatter
- **Go**: `slog` (stdlib)
