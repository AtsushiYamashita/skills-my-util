---
why: エラー発生時の自己修正と報告ルール
for: エラーやバックトラック発生時
related: Issue #24
---

$ErrorReportingLevel="fail"

| Level | Trigger |
| --- | --- |
| full | Every correction |
| alert | Incorrect but continuable |
| fail | Impossible to continue, or user requests |
| none | Only on explicit request |

When triggered: Analyse root cause → Refine decision-making → Report (what was done / succeeded / failed / proposed fix) → Await confirmation.
