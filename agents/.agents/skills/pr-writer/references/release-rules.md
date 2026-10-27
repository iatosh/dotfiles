# Release Rules

Read this file when the repo has releases (version files, tag workflow, or a
Releases section in CONTRIBUTING.md).

## When a release is triggered

Only changes inside `skills/` trigger a release. Changes outside `skills/`
(CONTRIBUTING.md, AGENTS.md, `.github/`, docs outside skills/, etc.) need no
release.

## Version bump rules

Semver. Determine the bump level from the commit type:

- `fix:` → **patch** (bump third number: 1.2.1 → 1.2.2)
- `docs:` or `refactor:` inside `skills/` → **patch**
- `feat:` → **minor** (bump second number: 1.2.1 → 1.3.0)
- `feat!:` or `BREAKING CHANGE:` footer → **major** (bump first number: 1.2.1 → 2.0.0)

## What users rely on (semver contract)

- How the skill is invoked and what steps a Conversion takes
- The scripts' command lines
- The Ledger and Attestation formats (old work must still resume)
- What output datasets contain

**Major bump** when something users rely on stops working:
- Ledger format old work cannot resume from
- Removed script option
- New check that stops datasets that used to pass

## Version files

Both must be updated to the same version in the same PR:
- `plugin.json`
- `.claude-plugin/plugin.json`

## Tagging and release

After merging, create and push the tag:

```bash
git tag -a vX.Y.Z -m vX.Y.Z
git push origin vX.Y.Z
```

The tag triggers `.github/workflows/release.yml`, which builds the skill zip
from `skills/eeg-bids-converter/` and creates the GitHub Release. Do not
manually build or upload the zip.
