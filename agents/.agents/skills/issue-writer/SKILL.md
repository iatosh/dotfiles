---
name: issue-writer
description: >
  Write a well-structured issue for this repository. Use this skill whenever
  the user wants to file, draft, or open an issue — including tasks, features,
  bugs, or research questions. Also use when the user says "I found a problem,"
  "we need to add X," "should we do Y," or "let's track this." Produces the
  issue body with the correct sections and flags what metadata to set
  (issue type, area label, priority, dependencies).
---

# Issue Writer

Produce a well-structured GitHub issue that follows the repository's rules
from CONTRIBUTING.md. The user has identified something that needs tracking;
your job is to shape it into an issue that a developer can pick up without
asking follow-up questions.

## Issue types

Every issue is exactly one type:

- **Task**: One piece of work ending in one pull request. Research and
  decisions are also Tasks — closed by recording the answer, not by code.
- **Feature**: A group of new functionality, the parent of Tasks. Features
  have no branch; each child Task branches from `main` separately.
- **Bug**: Something the skill does wrong — a wrong label, a crash, a broken
  output.

## Area labels

Every issue gets at least one area label. Pick the most specific one that
applies:

- `area:core` — Ledger, Checklist, Sources, rendering, finalize
- `area:eval` — evaluation harness
- `area:hooks` — agent hooks, Verifier, SKILL.md, client adapters
- `area:packaging` — plugin layout, release, install
- `area:dev` — CONTRIBUTING, AGENTS.md, GitHub templates and settings, dev
  environment, CI

Note: the skill's own hooks are `area:hooks`, not `area:dev`.

## Priority

Set the `Priority` issue field when the issue is opened:

- **Urgent**: stops other work
- **High**: taken next among ready issues
- **Medium**: the default
- **Low**: waits until nothing else is ready

Blockers decide order first; Priority chooses among issues that are ready.

## Dependencies

Set dependencies as **Blocked by** in the GitHub issue sidebar. Never write
dependencies in the issue body text. If the user mentions that work depends on
other issues, tell them to set the relationship in the sidebar after creating
the issue.

## Body format

### For a Task

```markdown
Set dependencies in the sidebar under Relationships (Blocked by), not in the text.

## Purpose

What changes and why. One or two sentences.

## Done when

Checks that someone else can run. Leave nothing to judgment.

- [ ] Specific, testable condition 1
- [ ] Specific, testable condition 2

## Out of scope

What this task must not touch, even if it looks related.

## Design references

Full links to docs on main (CONTEXT.md, ADRs, workflow.md).
```

### For a Feature (Epic)

```markdown
Set dependencies in the sidebar under Relationships (Blocked by), not in the text.

## Purpose

What is true once every sub-issue is closed.

## Parts

One line per planned sub-issue. Create each as a Task and add it under this issue as a sub-issue.

- Task 1: [brief description]
- Task 2: [brief description]

## Design references

Full links to docs on main.
```

### For a Decision or research

```markdown
## Question

The specific question to settle.

## Options known so far

List the options you've considered, if any.

## What settles it

The measurement, document, or test whose result decides the question.

## Record the answer in

[ ] docs/adr (new ADR)
[ ] docs/design.md
[ ] CONTEXT.md
```

### For a Bug (Conversion failure)

```markdown
Do not paste data, file contents, or names from Unpublished data. Give the location instead.

## Dataset

Name or accession (e.g. ds007), and where it came from.

## Work

[ ] Conversion
[ ] Audit
[ ] Amendment

## Client and model

e.g. Claude Code 2.1 with Sonnet, Codex 0.144 with GPT-5

## Skill version

Release tag or commit.

## What happened

The wrong value, error, or step where it stopped. Quote the shortest decisive line.

## What was expected

The right value and where it is stated (paper page, README line, originator).

## Ledger and logs

Path to the Ledger and the session log.
```

## Rules to enforce

1. **Links must be full URLs to `main`**. Plain text like "ADR-0002" is not
   linked. Convert any bare references to full GitHub URLs.
2. **"Done when" must be testable**. Each checkbox is something another
   developer can check off without guessing. If a criterion says "works
   correctly," ask for specifics.
3. **Out of scope is required for Tasks**. Even if it's just "nothing else" —
   force the user to think about what the task must not touch.
4. **No data in bug reports**. If the user pastes EEG data, filenames, or
   participant names into a bug report, tell them to replace it with a
   location (path or accession) and the type of data.
5. **One issue, one purpose**. If the user describes two separate things,
   split into two issues.

## Workflow

1. Ask the user: What's the issue about? What changed or what's broken?
2. Determine the issue type (Task, Feature, or Bug).
3. Draft the body using the appropriate template above.
4. Tell the user what metadata to set:
   - Issue type
   - Area label(s)
   - Priority (default to Medium if they don't specify)
   - Blocked by (if any)
5. If the user is creating the issue via the web, point them to the issue form.
   If they're using the API or gh CLI, provide the command.
