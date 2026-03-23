---
name: setup-pre-commit
description: Set up Lefthook pre-commit hooks with RuboCop (on staged files) and RSpec (on push) in the current repo. Use when user wants to add pre-commit hooks, set up Lefthook, run RuboCop before commits, or run tests before pushing.
---

# Setup Pre-Commit Hooks

## What This Sets Up

- **Lefthook** git hooks manager
- **RuboCop** running on staged `.rb` files at pre-commit
- **RSpec** running on staged spec files at pre-commit, and the full suite at pre-push

## Steps

### 1. Install Lefthook

Check how the project is set up:

- If there's a `Gemfile`, add lefthook as a dev dependency and install via Bundler:

  ```ruby
  # Gemfile
  group :development do
    gem "lefthook"
  end
  ```

  ```bash
  bundle install
  ```

- Otherwise, install via Homebrew:

  ```bash
  brew install lefthook
  ```

### 2. Create `lefthook.yml`

Create this file in the repo root:

```yaml
pre-commit:
  commands:
    rubocop:
      glob: "*.rb"
      run: bundle exec rubocop --force-exclusion {staged_files}
    rspec:
      glob: "spec/**/*_spec.rb"
      run: bundle exec rspec {staged_files}

pre-push:
  commands:
    rspec:
      run: bundle exec rspec
```

**Adapt**:
- If the repo has no RSpec setup, omit both `rspec` entries and tell the user.
- If the repo has no RuboCop setup, omit the `rubocop` command and tell the user.
- `{staged_files}` will be empty if no spec files are staged at commit time — in that case the pre-commit RSpec run is a no-op, which is fine.

### 3. Install the hooks

```bash
bundle exec lefthook install
```

This wires up the git hooks in `.git/hooks/`.

### 4. Verify

- [ ] `lefthook.yml` exists in repo root
- [ ] Run `bundle exec lefthook run pre-commit` to verify RuboCop and RSpec work
- [ ] Run `bundle exec lefthook run pre-push` to verify RSpec works

### 5. Commit

Stage all changed/created files and commit with message: `Add pre-commit hooks (lefthook + rubocop + rspec)`

This will run through the new pre-commit hooks — a good smoke test that everything works.

## Notes

- `{staged_files}` passes only staged files to each command, keeping pre-commit fast
- `--force-exclusion` ensures RuboCop respects any `Exclude` rules in `.rubocop.yml`
- Pre-commit RSpec only runs staged spec files — fast feedback on what you just touched
- Pre-push runs the full suite — catches anything you might have missed before code leaves your machine
- If no spec files are staged at commit time, the pre-commit RSpec step is a no-op
- `lefthook.yml` should be committed to the repo so the whole team gets the same hooks
- Lefthook can also be installed globally via `brew install lefthook` if you don't want it in the Gemfile
