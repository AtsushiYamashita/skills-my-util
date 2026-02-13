---
name: checking-cross-platform
description: Checks code, scripts, and documentation for cross-platform and cross-environment compatibility issues. Activates when writing shell scripts, CLI commands, installation instructions, README examples, or CI configs. Catches OS-specific syntax, shell differences, path separators, and version-dependent APIs.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Checking Cross Platform

Catch environment-specific assumptions before they become bugs.

## Activation

Activate when any of these are being written or modified:

- Shell scripts (`.ps1`, `.sh`, `.bash`, `.zsh`)
- CLI commands in documentation or README
- Installation or setup instructions
- CI/CD configuration files
- Code that calls OS-specific APIs or shell commands

## Workflow

```
Task Progress:
- [ ] Step 1: Identify target environments
- [ ] Step 2: Check against compatibility list
- [ ] Step 3: Fix or document platform-specific code
- [ ] Step 4: Provide cross-platform alternatives
```

**Step 1: Identify target environments**

Determine which environments the code must support:

- **OS**: Windows / macOS / Linux — which ones?
- **Shell**: PowerShell 5.x / PowerShell 7+ / bash / zsh
- **Runtime**: Node.js version, Python version, etc.
- **Package manager**: npm / pnpm / yarn / pip / uv

If not specified by the user, assume the broadest reasonable compatibility.

**Step 2: Check against compatibility list**

Apply the checklist in [references/compatibility-checklist.md](references/compatibility-checklist.md).

Key items to always check:

- Path separators (`/` vs `\`)
- Command syntax differences across shells
- API/function availability across versions
- Line endings (LF vs CRLF)
- Environment variable syntax (`$VAR` vs `$env:VAR` vs `%VAR%`)

**Step 3: Fix or document**

For each issue found:

- **If fixable**: provide cross-platform code
- **If platform-specific by nature**: document the requirement clearly

```markdown
> [!NOTE]
> Windows requires Administrator privileges or Developer Mode
> for symbolic link creation.
```

**Step 4: Provide alternatives in docs**

When writing README or installation instructions, provide commands for each supported platform:

````markdown
```powershell
# Windows (PowerShell)
.\scripts\setup.ps1 -t antigravity
```

```bash
# macOS / Linux
./scripts/setup.sh -t antigravity
```
````
