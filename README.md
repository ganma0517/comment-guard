# comment-guard

`comment-guard` is a small repository guardrail for teams using AI coding agents. It blocks change-history comments such as "fixed", "updated", "NEW", and "as requested" before they enter commits.

It does not try to judge every comment. The goal is deliberately narrow: stop the obvious low-value comments that AI agents often imitate and spread.

## Why This Exists

AI coding agents often leave comments that explain the edit session rather than the software. Once those comments land in a repository, later agents may copy the style and produce more of the same.

The durable fix is layered:

1. Clean bad examples from the repository.
2. Put comment rules in `CLAUDE.md` or `AGENTS.md`.
3. Add a pre-commit or CI check.
4. Keep human review for subtle cases that automation cannot detect.

## Install

From this package directory:

```bash
cd your-repo
/path/to/comment-guard/install.sh
```

Optional:

```bash
/path/to/comment-guard/install.sh --agents-md
/path/to/comment-guard/install.sh --ci
/path/to/comment-guard/install.sh --global
```

## Use

```bash
tools/check_comments.sh --all
tools/check_comments.sh
tools/check_comments.sh --range main..HEAD
```

## Customize

Create `.commentguard` in the repository root. Add one regular expression per line.

To exempt a single line, add:

```text
comment-guard: ignore
```

## Teaching Material

Open [`docs/index.html`](docs/index.html) for a compact lecture on the problem, evidence, and rollout strategy.

## Limits

- The script blocks fixed phrases, not every bad comment.
- Redundant comments that simply repeat code still require review.
- Documentation comments for public APIs are not the target.
- Research notes, data provenance notes, and ethics notes should be preserved when they explain why a decision was made.
