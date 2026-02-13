# Compatibility Checklist

Code and documentation must be checked against this list before completion.

## PowerShell

| Item                    | PS 5.x (Windows built-in) | PS 7+ (cross-platform) |
| ----------------------- | ------------------------- | ---------------------- |
| `Join-Path` args        | **2 args only**           | 3+ args supported      |
| `&&` operator           | ❌ Not supported          | ✅ Supported           |
| `Test-Json`             | ❌ Not available          | ✅ Available           |
| Ternary `? :`           | ❌ Not supported          | ✅ Supported           |
| `$null` coalescing `??` | ❌ Not supported          | ✅ Supported           |
| Pipeline chain `\|\|`   | ❌ Not supported          | ✅ Supported           |
| Default encoding        | UTF-16 LE (BOM)           | UTF-8 (no BOM)         |

**Rule**: Unless PS 7+ is explicitly required, write PS 5.x-compatible code.

## Path Separators

| Context                      | Correct             | Incorrect       |
| ---------------------------- | ------------------- | --------------- |
| Script internal paths        | `Join-Path` or `/`  | Hardcoded `\`   |
| SKILL.md / README references | `/` (forward slash) | `\` (backslash) |
| Git paths                    | `/` always          | `\`             |
| Windows registry             | `\` (required)      | `/`             |

## Shell Commands in Documentation

| Task           | PowerShell            | bash/zsh             |
| -------------- | --------------------- | -------------------- |
| Run script     | `.\scripts\setup.ps1` | `./scripts/setup.sh` |
| Set env var    | `$env:FOO = "bar"`    | `export FOO=bar`     |
| Read env var   | `$env:FOO`            | `$FOO`               |
| Chain commands | `cmd1; cmd2`          | `cmd1 && cmd2`       |
| Home directory | `$env:USERPROFILE`    | `$HOME` or `~`       |
| Null device    | `$null`               | `/dev/null`          |
| List files     | `Get-ChildItem`       | `ls`                 |

## Line Endings

| Context          | Expected                      |
| ---------------- | ----------------------------- |
| `.sh` scripts    | LF only (CRLF breaks shebang) |
| `.ps1` scripts   | CRLF or LF (both work)        |
| `.gitattributes` | Use `* text=auto`             |

## Symlinks

| OS            | Requirement                                        |
| ------------- | -------------------------------------------------- |
| Windows       | Administrator privileges or Developer Mode enabled |
| macOS / Linux | No special permissions                             |

**Rule**: When using symlinks, always document the Windows permission requirement.

## CI/CD

| Item          | Check                                                     |
| ------------- | --------------------------------------------------------- |
| Shell         | Specify `shell: bash` or `shell: pwsh` explicitly         |
| OS matrix     | Test on `ubuntu-latest`, `windows-latest`, `macos-latest` |
| Path handling | Use `${{ runner.os }}` for conditional paths              |
