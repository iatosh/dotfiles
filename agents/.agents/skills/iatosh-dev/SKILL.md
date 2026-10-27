---
name: iatosh-dev
description: >
  Repository-aware development workflow for iatosh's repositories. Use this
  skill when working in any iatosh-owned repo (bids-converter or others) and
  the task involves: creating an issue, opening a PR, deciding on a version
  bump, following the repo's contribution process, or checking whether a
  change needs a release. This skill reads the repo's CONTRIBUTING.md and
  AGENTS.md, delegates to issue-writer or pr-writer with the correct rules,
  and flags any repo-specific requirements. Do NOT use for general code
  editing, debugging, or questions about the codebase that don't touch the
  contribution workflow.
---

# iatosh-dev

Orchestrates the correct contribution workflow based on the repository's
own rules. You are working in an iatosh-owned repo; this skill ensures the
issue, PR, versioning, and release steps follow that repo's CONTRIBUTING.md
and AGENTS.md.

## When to delegate

| User intent | Delegate to |
|---|---|
| "Write an issue for..." | `issue-writer` |
| "Ship this" / "PR for..." / "Release the version" | `pr-writer` |

## Workflow

1. **Identify the repo.** Run `git remote -v` or check the working directory to determine which iatosh repo you're in.

2. **Read the repo's rules.** Read `CONTRIBUTING.md` and `AGENTS.md` (if they exist). These files are the source of truth for:
   - Issue types and area labels
   - Priority rules
   - Branch naming
   - PR body requirements
   - Version bump rules and release triggers
   - Data safety rules

3. **Check for repo-specific release rules.** If `references/release-rules.md` exists (relative to the pr-writer skill), it contains detailed release rules for a specific repo. Pass it to pr-writer.

4. **Delegate with context.**
   - For issues: Tell `issue-writer` the repo name so it knows which issue type labels and area labels to use. Pass the issue type, area labels, and any blocker relationships the user mentioned.
   - For PRs: Tell `pr-writer` which files changed, whether they're inside `skills/` (or the repo's release-trigger directory), and the issue number. Let it determine the version bump.

5. **Report back.** Present the generated issue body or shipping artifacts to the user. Flag any repo-specific rules they need to set manually (sidebar fields, labels, etc.).

## Key differences across iatosh repos

Repos may differ in:
- Which directory triggers a release (`skills/` in bids-converter, may differ elsewhere)
- Version file names (`plugin.json`, `package.json`, `pyproject.toml`, etc.)
- Issue type and label schemes

Always read the specific repo's CONTRIBUTING.md first; do not assume rules
transfer between repos.
