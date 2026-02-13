# Question Bank

Domain-specific question templates for the Expand step. Load when the user's idea falls into one of these categories.

## Web Application

- What devices/browsers must be supported?
- Does the user need to log in? What identity provider?
- Is there existing data to migrate or an API to integrate?
- Real-time features needed? (notifications, live updates)
- What does a typical user session look like, start to finish?

## CLI Tool

- What shell environments must be supported? (bash, PowerShell, fish)
- Pipe-friendly output needed? (JSON, TSV, plain)
- Interactive prompts or fully non-interactive?
- What existing tools does this replace or complement?
- How will users install it? (npm, brew, standalone binary)

## Library / SDK

- Who are the consumers? (internal team, OSS community, enterprise)
- What is the public API surface — methods, not internals?
- What languages/runtimes must be supported?
- Versioning strategy? Breaking change tolerance?
- Are there competing libraries? What gap does yours fill?

## Agent Skill

- What triggers this skill? Give example user utterances.
- What tools or resources does the skill need access to?
- What does the output look like?
- Should it be standalone or compose with other skills?
- What would a bad result look like? (defines anti-patterns)

## Document / Report

- Who is the audience? What decision will they make based on this?
- What format? (Markdown, PDF, PPTX, DOCX)
- Are there existing templates or style guidelines?
- What data sources feed into this?
- What level of detail? (executive summary vs. deep dive)

## Automation / Script

- What manual process does this replace?
- How often does it run? (on-demand, scheduled, event-driven)
- What happens if it fails? Who gets notified?
- What credentials/permissions are required?
- Is idempotency important?

## Universal Questions

These apply regardless of domain:

- What does "done" look like? How do you know it's working?
- What's the simplest version that would still be useful?
- What have you tried so far? What did/didn't work?
- Is there anything similar you've seen that you liked?
- What's the deadline, if any?
