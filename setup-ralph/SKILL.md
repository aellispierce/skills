---
name: setup-ralph
description: Set up Ralph Wiggum autonomous coding loop scripts in ./plans/. Creates ralph.sh (multi-iteration AFK loop) and ralph-once.sh (single interactive HITL run), both wired to GitHub issues as the task source. Run once per repo. Use when user wants to set up Ralph, create a coding agent loop, or set up autonomous AFK coding.
---

# Setup Ralph

## What This Sets Up

- `./plans/ralph-once.sh` — single interactive run (HITL). Use this first to learn the loop and verify your prompt.
- `./plans/ralph.sh` — multi-iteration AFK loop with a max iterations cap. Use this once you trust the prompt.
- `./plans/progress.txt` — Ralph's memory file. Append-only during a sprint, deleted when the sprint is done.

Ralph reads open GitHub issues as its task source. By default it reads all open issues, but you can scope it at runtime with optional flags.

## Steps

### 1. Confirm prerequisites

- [ ] `gh` CLI is installed and authenticated (`gh auth status`)
- [ ] Repo has at least one open issue
- [ ] Feedback loops are set up (RSpec + RuboCop via lefthook, or equivalent)

### 2. Create `./plans/` if it doesn't exist

```bash
mkdir -p plans
```

### 3. Create `./plans/ralph-once.sh`

```bash
#!/bin/bash
set -e

# Parse optional args
# Usage: ./ralph-once.sh [--milestone <name>] [--issue <number>]
GH_ARGS="--state open --json number,title,body"
SINGLE_ISSUE=false
ISSUE_NUMBER=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --milestone) GH_ARGS="$GH_ARGS --milestone $2"; shift ;;
    --label) GH_ARGS="$GH_ARGS --label $2"; shift ;;
    --issue) SINGLE_ISSUE=true; ISSUE_NUMBER="$2"; shift ;;
  esac
  shift
done

# Fetch issues
if [ "$SINGLE_ISSUE" = true ]; then
  ISSUES=$(gh issue view "$ISSUE_NUMBER" --json number,title,body)
else
  ISSUES=$(gh issue list $GH_ARGS)
fi

if [ -z "$ISSUES" ] || [ "$ISSUES" = "[]" ]; then
  echo "No open issues found. Nothing to do."
  exit 0
fi

claude --permission-mode acceptEdits -p \
"@plans/progress.txt

Here are the open GitHub issues for this sprint:
$ISSUES

1. Review progress.txt to understand what has already been done this sprint.
2. Pick the single highest priority open issue. This should be the one YOU decide has highest priority — not necessarily the first in the list.
3. Explore the codebase as needed to understand what needs to change.
4. Implement the issue. Keep the change small and focused.
5. Run feedback loops: bundle exec rubocop --force-exclusion and bundle exec rspec. Do NOT commit if either fails. Fix issues first.
6. Append a brief note to plans/progress.txt: issue number, what you did, files changed, anything notable for the next iteration.
7. Close the issue: gh issue close <number> --comment 'Implemented in <commit sha>'
8. Make a single focused git commit covering your changes and the progress.txt update.
ONLY WORK ON A SINGLE ISSUE.
If all issues are closed, output exactly: <promise>COMPLETE</promise>"
```

### 4. Create `./plans/ralph.sh`

```bash
#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <max_iterations> [--milestone <name>] [--issue <number>]"
  exit 1
fi

MAX_ITERATIONS=$1
shift

# Parse optional args
GH_ARGS="--state open --json number,title,body"
SINGLE_ISSUE=false
ISSUE_NUMBER=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --milestone) GH_ARGS="$GH_ARGS --milestone $2"; shift ;;
    --label) GH_ARGS="$GH_ARGS --label $2"; shift ;;
    --issue) SINGLE_ISSUE=true; ISSUE_NUMBER="$2"; shift ;;
  esac
  shift
done

for ((i=1; i<=$MAX_ITERATIONS; i++)); do
  echo ""
  echo "=== Ralph iteration $i / $MAX_ITERATIONS ==="
  echo ""

  # Fetch issues fresh each iteration
  if [ "$SINGLE_ISSUE" = true ]; then
    ISSUES=$(gh issue view "$ISSUE_NUMBER" --json number,title,body)
  else
    ISSUES=$(gh issue list $GH_ARGS)
  fi

  if [ -z "$ISSUES" ] || [ "$ISSUES" = "[]" ]; then
    echo "No open issues found. Exiting."
    exit 0
  fi

  result=$(claude --permission-mode acceptEdits -p \
"@plans/progress.txt

Here are the open GitHub issues for this sprint:
$ISSUES

1. Review progress.txt to understand what has already been done this sprint.
2. Pick the single highest priority open issue. This should be the one YOU decide has highest priority — not necessarily the first in the list.
3. Explore the codebase as needed to understand what needs to change.
4. Implement the issue. Keep the change small and focused.
5. Run feedback loops: bundle exec rubocop --force-exclusion and bundle exec rspec. Do NOT commit if either fails. Fix issues first.
6. Append a brief note to plans/progress.txt: issue number, what you did, files changed, anything notable for the next iteration.
7. Close the issue: gh issue close <number> --comment 'Implemented in <commit sha>'
8. Make a single focused git commit covering your changes and the progress.txt update.
ONLY WORK ON A SINGLE ISSUE.
If all issues are closed, output exactly: <promise>COMPLETE</promise>")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "All issues complete. Exiting."
    exit 0
  fi
done

echo "Reached max iterations ($MAX_ITERATIONS)."
```

### 5. Make scripts executable

```bash
chmod +x plans/ralph.sh plans/ralph-once.sh
```

### 6. Create `./plans/progress.txt`

```
# Ralph Progress Log
# Repo: <repo name>
# Started: <date>
```

### 7. Commit the scripts

```bash
git add plans/ralph.sh plans/ralph-once.sh
git commit -m "Add Ralph scripts"
```

Note: add `plans/progress.txt` to `.gitignore` — it is session-specific scratch space, not permanent documentation.

## Usage

```bash
# HITL — watch a single iteration
./plans/ralph-once.sh

# HITL — scoped to one specific issue
./plans/ralph-once.sh --issue 26

# HITL — scoped to a label
./plans/ralph-once.sh --label billing

# HITL — scoped to a milestone
./plans/ralph-once.sh --milestone sprint-1

# AFK — run up to 10 iterations over all open issues
./plans/ralph.sh 10

# AFK — scoped to a label
./plans/ralph.sh 10 --label billing

# AFK — scoped to a milestone
./plans/ralph.sh 10 --milestone sprint-1

# AFK — scoped to a single issue
./plans/ralph.sh 5 --issue 26
```

## Workflow with other skills

The intended full workflow:

1. `write-a-prd` → creates a GitHub issue with the PRD
2. `prd-to-issues` → breaks the PRD into small vertical-slice GitHub issues
3. `setup-ralph` → run once per repo to create the scripts (this skill)
4. `./plans/ralph-once.sh` → first run per sprint, watch it, verify everything works
5. `./plans/ralph.sh <n>` → AFK once you trust the loop

GitHub issues are the single source of truth. Ralph closes issues as it completes them. Nothing to sync.

## Notes

- Always run ralph-once.sh first on a new repo to verify your feedback loops are working before going AFK
- Keep issues small. Oversized tasks are the main failure mode. If an issue would take a human more than a couple of hours, split it.
- `progress.txt` is Ralph's memory across iterations. Without it each run starts blind.
- Delete `progress.txt` when the sprint is done — it is session-specific, not permanent docs.
- Fetching issues fresh on each iteration means Ralph always sees the current state — if you close or add issues mid-loop it will pick them up automatically.
