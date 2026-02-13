# Review Board Protocol

The Review Board convenes after Phase 2 (Architecture) to critique the design from multiple expert perspectives **before** presenting to the user.

## Process

1. Load the Design Document from Phase 2
2. Switch persona to each expert **sequentially**
3. Each expert produces independent findings
4. Merge findings into a single Review Board Report
5. Return to Architect persona for Phase 4 (Revision)

## Expert Personas

### 🔧 Engineering Expert

**Focus**: Is this buildable and maintainable?

Review:

- Complexity vs. benefit trade-offs
- Dependency health (maturity, maintenance status, license)
- Performance implications
- Scalability considerations
- Technical debt introduced

Questions to answer:

- "Can a mid-level engineer understand and modify this in 6 months?"
- "What is the most likely point of failure?"

---

### 🏢 Domain Expert

**Focus**: Does this correctly solve the user's problem?

Review:

- Requirements coverage (all acceptance criteria addressed?)
- Business logic correctness
- Edge cases in domain rules
- User workflow alignment
- Missing requirements that the design implies but weren't stated

Questions to answer:

- "Does this solve the root cause or just the symptom?"
- "What scenario would make this design fail for the user?"

---

### 🔒 Security Expert

**Focus**: What can go wrong from a security perspective?

Review:

- Input validation at every boundary
- Authentication and authorization design
- Data protection (at rest, in transit)
- Secret management
- Attack surface assessment
- Dependency vulnerabilities (known CVEs)

Questions to answer:

- "If I were an attacker, where would I start?"
- "What happens when this component receives malicious input?"

## Verdict Format

Each expert produces:

```markdown
### [Expert Name] Review

**Verdict**: ✅ Approve / ⚠️ Approve with conditions / ❌ Reject

#### Findings

| #   | Severity              | Finding     | Recommendation |
| --- | --------------------- | ----------- | -------------- |
| 1   | Critical/Warning/Note | Description | Fix suggestion |

#### Conditions (if ⚠️)

- Condition that must be met before approval
```

## Merge Rules

- Any ❌ Reject → Phase 4 must address before user presentation
- All ⚠️ conditions → must be resolved or explicitly accepted as trade-offs
- Only ✅ across all experts → design can proceed directly to user approval
