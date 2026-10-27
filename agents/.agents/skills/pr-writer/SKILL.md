---
name: pr-writer
description: >
  Write a correct commit message, branch name, and pull request for changes
  that are ready to ship. Use this skill whenever the user wants to commit
  finished work, open a PR, merge a branch, or cut a release — even if they
  only say "ship this" or "release the version". Handles conventional commit
  messages, branch naming from the issue number, PR body with closes
  reference, squash vs merge-commit decision, and semantic version bump
  (major/minor/patch) with tag creation. Also use when the user asks whether
  a change needs a release or what version number to use.
---

# PR Writer

Produce the shipping artifacts for finished work: branch name, commit message,
PR body, version bump, and release tag. The user has already implemented the
change; your job is to package it correctly.

## When this applies

This skill codifies the repository's CONTRIBUTING.md rules. Use it for every
PR and release in this repo. If a rule is missing here, fall back to the
project's CONTRIBUTING.md.

## Inputs you need

Before writing anything, confirm:

1. **What changed?** Run `git diff --stat` (or `git diff main...HEAD` on a
   feature branch) to see the changed files and scope.
2. **Which issue?** The branch name encodes the issue number. Ask the user or
   extract it from the branch name (pattern: `issue-<number>-<slug>`).
3. **Is the change inside `skills/`?** Only changes inside `skills/` trigger a
   release. Changes outside need no release and no version bump.

## Workflow

### 0. Verify the work is complete

Before writing any shipping artifacts, check that the work actually meets the
issue's "Done when" criteria:

1. Read the issue body. Find the "Done when" section.
2. For each checkbox, verify it's actually true in the code.
   - If it says "script exits with non-zero on error," run the script with bad input.
   - If it says "documented in workflow.md," check the file.
3. If any criterion is unmet, tell the user what's missing and stop. Don't
   proceed to shipping.
4. If the issue has "Out of scope" items, verify the PR doesn't accidentally
   touch them.

**Data safety check** — run `git diff --name-only` (or `git diff main...HEAD --name-only` on a feature branch) and verify:
- No signal data files (EDF, EEGLAB .set, BDF, GDF, CNT, raw .mat, or anything that looks like EEG recordings)
- No Unpublished data (files from private datasets not yet released)
- No files copied from the NAS without being transformed

If any of these appear, stop and tell the user. Do not ship them.

If the user hasn't given you an issue number, ask for it before proceeding.

### 1. Branch name

Pattern: `issue-<number>-<slug>`

- `<number>`: the issue number (not the PR number)
- `<slug>`: short kebab-case summary, 2-4 words

Branch from `main` only. If the user is on a different branch, note that and
ask.

### 2. Commit message

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short imperative summary>

<body explaining why, if needed>
```

Types:
- `feat:` — new functionality (triggers minor version bump)
- `fix:` — bug fix (triggers patch version bump)
- `docs:` — documentation only (patch if inside `skills/`, no release if outside)
- `refactor:` — code change with no behavior change (patch if inside `skills/`)
- `chore:` — tooling, dependencies, CI
- `test:` — test changes

Rules:
- Summary is imperative, lowercase, no period: `fix: name the key in validator warnings`
- Breaking changes use `!` before the colon: `feat!: remove --legacy flag` or add a `BREAKING CHANGE:` footer to the body
- No `Co-Authored-By` or other generated trailers
- One commit per PR is the goal; if multiple commits exist, they should be
  squashed (see merge strategy below)

### 3. PR body

First line must be:

```
Closes #<issue-number>
```

Then optionally:
- Summary of what changed and why (if the commit message isn't enough)
- Test plan: how to verify the change works
- Design change note: if the PR changes CONTEXT.md, an ADR, or `docs/`, list
  which files and what changed

**Design changes must be in the same PR.** If the work changed the design (new
terminology in CONTEXT.md, an architectural decision), that documentation must
be included in the same pull request — not a follow-up.

Keep the PR body short. The commit message carries the detail.

### 4. Merge strategy

Default: **squash merge**. Every PR becomes one commit on `main`.

Use a **merge commit** only when every commit in the PR stands alone — each
has a valid conventional commit message and the code works at that commit.
Example: a file move kept separate from edits to the moved files. If you use a
merge commit, say so in the PR body.

### 5. Version bump and release

Check whether the repo has versioning and release rules. Look in:
- CONTRIBUTING.md (Releases section)
- package.json, plugin.json, or similar version files
- Release workflows in CI configuration

If the repo uses semantic versioning, determine the bump level:
- **patch**: bug fix (`fix:`), docs, refactor, test-only changes
- **minor**: new feature, backward-compatible (`feat:`)
- **major**: breaking change (`feat!:`, `BREAKING CHANGE:` footer)

**Repo-specific release rules:** If the repo has releases, read
`references/release-rules.md` for details on when a release is triggered, the
semver contract, version files to edit, and tag workflow. If the file doesn't
exist or the repo has no release process, skip this step.

## Common mistakes to avoid

- Using the PR number instead of issue number in the branch name or `Closes`
- Writing `Co-Authored-By` trailers
- Using a merge commit when squash would work (default to squash)
