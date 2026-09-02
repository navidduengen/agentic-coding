# agentic-coding

My Claude Code configuration: global rules, skills, sub-agents, hooks and settings. Linked into `~/.claude` via symlinks so the repo is the single source of truth.

Forked from [sammcj/agentic-coding](https://github.com/sammcj/agentic-coding) (Apache-2.0). Most skills and the hook code are Sam McLeod's work, trimmed and adapted. Upstream stays configured as `upstream`; changes are cherry-picked file by file, not merged.

## Layout

- `Rules/CLAUDE.md` - global instructions, loaded in every session. Kept under 60 lines on purpose.
- `Rules/CLAUDE-WEB.md` - optional variant for claude.ai project instructions.
- `Skills/` - agent skills, one directory per skill with a `SKILL.md`. Loaded on demand.
- `Claude/agents/` - sub-agents (critical-reviewer, step-back, quick-researcher, software-research-assistant, compression-editor).
- `Claude/commands/` - slash commands (`/compact-prep`).
- `Claude/hooks/` - `approve-compound-commands` (Go, auto-approves piped and chained commands when every part is allow-listed) and `allow-skills-edit.sh` (lets Claude edit its own skills without prompting).
- `Claude/output-styles/terse.md` - optional output style, enable with `/output-style terse`.
- `Claude/settings.json` - permissions (allow, ask, deny), sandbox, hooks, plugins, status line.
- `Claude/statusline-command.sh` - context usage and rate-limit status line. Needs `jq`.

## Install

```bash
./install.sh
```

Symlinks everything into `~/.claude`, builds the Go hook and installs the pre-commit hook. Existing files are moved to `.backup-before-install/`. Requires `jq`, optionally `go` and `pre-commit`.

Warp scans `~/.claude/skills/` as well, so the skills are available there without extra setup.

## Maintenance

- Regel ändern: Datei hier editieren, fertig. Die Symlinks zeigen direkt hierher.
- Claude Code schreibt selbst in `settings.json` (Plugin-Installationen, Permission-Freigaben). Das Repo wird dadurch dirty, einfach committen.
- Upstream sichten: `git fetch upstream && git log --oneline main..upstream/main -- Skills Claude`. Einzelne Skills holen mit `git checkout upstream/main -- Skills/<name>`.
- Neue Skills nur anlegen, wenn du dieselbe Erklärung zum zweiten Mal gibst. Vorher `skill-creator-primer` lesen.

## Working rules I keep coming back to

Condensed from Sam's tips, kept because they match my experience:

- Only add rules for behaviour that differs from the default. Review them with the aim to reduce.
- Skills over rules: anything longer than ten lines that is needed only sometimes becomes a skill.
- Hooks over prompts for anything that must happen every time.
- Fresh sessions aggressively. When stuck, have the agent write a handoff and start over.
- No MCP server where a CLI does the job.
- After a hard-won fix, ask the agent what led it astray and turn the answer into a rule or skill.

## License

Apache-2.0, see [LICENSE](./LICENSE). Original work by Sam McLeod.
