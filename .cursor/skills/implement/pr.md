# Pull request

Run this only in Phase 4, after the working branch exists and is not the default
branch (`main`, `master`, or `defaultBranchRef` from `gh repo view`). Do not
commit on the default branch.

## Gates

1. Commit uncommitted shippable work first. Never commit secrets (`.env`,
   `config/credentials`, `*.key`).
2. One concern per commit. Subject and PR title follow
   `.cursor/rules/git-commits.mdc`:

   ```
   <type>(<optional-scope>): <imperative description>
   ```

   Lowercase type, optional lowercase scope, imperative description, no trailing
   period, under 72 characters. Blank line before a body or footer. Issue links
   go in the footer, not the subject.
3. Run `bin/ci` from the repo root on the host. Do not wrap it in
   `docker compose exec web`. Do not pass `--native`.
4. If `bin/ci` is missing or exits non-zero, stop. Do not push, do not open the
   PR, and do not fix CI unless the user asks.
5. Push and `gh pr create` only after `bin/ci` exits 0.
6. Link the Phase 0 issue with `Fixes #<N>` in the PR body (use `Refs #<N>` when
   the issue must not auto-close).
7. Comment the PR URL on that issue.
8. Return the PR URL, base ← head, CI outcome, issue link, and whether a commit
   was created.

## Commit

Inspect status, diff, and recent subjects before committing. Stage only the
shippable files for this issue.

```bash
git status
git diff
git log -8 --oneline
git add <paths>
git commit -m "$(cat <<'EOF'
feat(scope): imperative description

Fixes #N
EOF
)"
```

Do not update git config. Do not skip hooks. Do not amend unless the user
explicitly asked and the commit is still local and unpushed.

## Push and open

```bash
git push -u origin HEAD
gh pr create --title "<type>(<scope>): <imperative description>" --body "$(cat <<'EOF'
## Summary
- <what changed and why>

## Test plan
- [ ] <how to verify>

Fixes #N
EOF
)"
```

Do not force-push. After the PR exists:

```bash
gh issue comment <N> --body "<pr url>"
```
