---
name: implement
description: >-
  Reads a GitHub issue, loads applicable .cursor/rules, builds an implementation
  plan, creates a working branch before any code change, then implements the
  feature or fix with TDD (RSpec + Playwright E2E when needed) and opens a
  GitHub pull request after a green local bin/ci. Default
  models: opus-high for planning, grok-higher-fast for implementation,
  composer-2.5 for E2E. Never use max-effort/max-mode models. Use when the user
  asks to implement an issue, work on #123, fix a GitHub issue, ship a ticket,
  create a PR, open a pull request, submit a PR, or finish the current branch.
context: fork
agent: general-purpose
model: sonnet
user-invocable: true
argument-hint: "<issue> [plan-with=<model>] [implement-with=<model>] [e2e-with=<model>]"
---

# Implement (GitHub issue)

You are an **orchestrator** that ships work from a GitHub issue following this
project's rules. **Never write production code until Phase 0 and Phase 1 complete
and the working branch exists.**

**Pipeline (fixed order):**

0. **Issue + rules gate** — fetch issue, predict layers, read every applicable
   `.cursor/rules/` file (orchestrator; mandatory)
1. **Plan** — delegated read-only subagent produces the implementation plan
   (default: `opus-high`)
2. **Branch, then implement** — create the working branch before any file edit,
   then a delegated subagent writes code and RSpec tests (default:
   `grok-higher-fast`)
3. **E2E tests** — delegated subagent adds/runs Playwright specs when the issue
   touches user-facing flows (default: `composer-2.5`)
4. **Pull request** — commit shippable work, run `bin/ci`, and open the PR only
   if CI is green ([pr.md](pr.md))

## Invocation

Parse flags from the user's message.

**PR only** (create/open/submit a PR, or finish the current branch, with no new
implementation): skip Phases 0–3 and run [Phase 4](#phase-4--pull-request-ci-gated).

**Implement an issue:** the issue is required, then run Phases 0–4. Skip Phase 4
only when the user explicitly said not to open a PR.

| Input | Example |
|-------|---------|
| Issue number | `implement #42` or `implement 42` |
| Issue URL | `implement https://github.com/org/repo/issues/42` |

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `plan-with=<model>` | `opus-high` | Model for Phase 1 planning |
| `implement-with=<model>` | `grok-higher-fast` | Model for Phase 2 implementation |
| `e2e-with=<model>` | `composer-2.5` | Model for Phase 3 E2E tests |

### Model slugs

Resolve aliases before launching each subagent:

| Alias | Task model slug |
|-------|-----------------|
| `opus-high` | `claude-opus-5-thinking-high` |
| `opus-5-high` | `claude-opus-5-thinking-high` |
| `grok-higher-fast` | `cursor-grok-4.6-high-fast` |
| `grok-4.6-high-fast` | `cursor-grok-4.6-high-fast` |
| `grok-4.5-high-fast` | `cursor-grok-4.5-high-fast` |
| `grok-fast` | `grok-4.5-fast-xhigh` |
| `composer-2.5` | `composer-2.5-fast` |
| `composer-2.5-fast` | `composer-2.5-fast` |
| `codex` | `gpt-5.3-codex` |

If the user passes an unknown slug, stop and list valid options — do not guess.

### Never use max effort

**Never select a max-effort or max-mode model variant** for any phase, and never
request extended/maximum reasoning effort. Use the `-high` tier as the ceiling
(e.g. `claude-opus-5-thinking-high`). If the user asks for a `max` variant,
substitute the equivalent `-high` slug and say so in your summary.

```text
implement #42
→ Phase 0 (issue + rules) → plan-with (opus-high) → create branch
  → implement-with (grok-higher-fast) → e2e-with (composer-2.5) → pull request

implement #42 implement-with=opus-high
→ Phase 0 → plan-with (opus-high) → create branch → implement-with (opus-high) → e2e-with (composer-2.5) → pull request

implement #42 plan-with=codex e2e-with=grok-higher-fast
→ Phase 0 → plan-with (codex) → create branch → implement-with (grok-higher-fast) → e2e-with (grok-higher-fast) → pull request
```

## Phase 0 — Issue + rules gate (mandatory)

Run Phase 0 **before** launching any subagent.

### Step 1 — Fetch the GitHub issue

Resolve the issue number from `#N`, a bare number, or a GitHub URL. Fetch with `gh`:

```bash
gh issue view <number> --json number,title,body,state,labels,comments,url,assignees
```

If comments matter for requirements, also fetch them:

```bash
gh issue view <number> --comments
```

**Blockers:** If `gh` fails (auth, not found, closed issue the user still wants
shipped), report clearly and stop unless the user pasted the issue body in chat.

Produce an **Issue summary** block:

```text
## Issue summary
- **#N:** <title> (<url>)
- **State:** open | closed
- **Labels:** …
- **Requirements:** bullet list distilled from title, body, and relevant comments
- **Acceptance criteria:** explicit or inferred checklist
- **Out of scope:** what the issue does NOT ask for (prevents scope creep)
```

### Step 2 — Predict affected layers

From the issue summary, list which parts of the app will likely change. Map
keywords and intent to layers (read rules for every layer you predict):

| Layer / area | Triggers in issue |
|--------------|-------------------|
| `models` | model, validation, association, enum, ActiveRecord |
| `controllers` | controller, route, endpoint, REST, CRUD, request |
| `services` | service, business logic, orchestration, transaction |
| `queries` | query object, scope, filter, search, report |
| `policies` | authorization, Pundit, permission, role, policy |
| `jobs` | background job, Sidekiq, async, deliver_later |
| `mailers` | email, mailer, notification |
| `migrations` | migration, column, index, schema, database |
| `views` | view, ERB, partial, UI, layout, form |
| `hotwire-frontend` | Turbo, Stimulus, stream, frame, Hotwire |
| `javascript-rails` | Stimulus controller, JS, importmap |
| `testing` | spec, test, RSpec (always when implementing behavior) |
| `rails-security` | auth, CSRF, XSS, mass assignment, Pundit |
| `rails-database-performance` | N+1, index, performance, query |

When uncertain, **include the layer** — reading an extra rule is cheaper than
violating a convention. Default `testing` on every implementation.

### Step 3 — Build the rules manifest

**Always read** (every implementation):

| File | Why |
|------|-----|
| `.cursor/rules/development-principles.mdc` | TDD, surgical changes, KISS/YAGNI, layer SRP |
| `.cursor/rules/rails-overview.mdc` | Index — confirms no rule file was missed |
| `.cursor/rules/anti-patterns.mdc` | Avoid god models, service graveyard, callback spaghetti |
| `.cursor/rules/testing.mdc` | RSpec, Better Specs, co-located specs |
| `AGENTS.md` | Docker-only CLI, RSpec, Better Specs |

**Also read** each layer/topic rule matching the predicted layers from Step 2:

| Rule file | Applies to |
|-----------|------------|
| `models.mdc` | `app/models/`, `spec/models/`, `spec/factories/` |
| `controllers.mdc` | `app/controllers/`, `spec/requests/` |
| `services.mdc` | `app/services/`, `spec/services/` |
| `queries.mdc` | `app/queries/`, `spec/queries/` |
| `policies.mdc` | `app/policies/`, `spec/policies/` |
| `jobs.mdc` | `app/jobs/`, `spec/jobs/` |
| `mailers.mdc` | `app/mailers/`, mailer views, `spec/mailers/` |
| `migrations.mdc` | `db/migrate/`, `db/schema.rb` |
| `views.mdc` | `app/views/`, `app/components/`, `app/presenters/` |
| `ruby-code-style.mdc` | `**/*.rb` (any Ruby change) |
| `rails-database-performance.mdc` | `app/models/`, `db/` |
| `rails-security.mdc` | `app/controllers/`, `app/policies/` |
| `hotwire-frontend.mdc` | `app/views/`, `app/assets/` |
| `javascript-rails.mdc` | `app/javascript/` |

De-duplicate — each file is read once.

### Step 4 — Read every file in the manifest

Use the Read tool to open **each** rule file in full. Skimming or relying on
prior sessions is **not** sufficient.

Produce a **Rules loaded** block:

```text
## Rules loaded
- Always-on: development-principles, rails-overview, anti-patterns, testing, AGENTS.md
- Layer/topic (from issue): models, controllers, services, …
- Predicted touchpoints: <brief list of dirs/files likely to change>
```

### Step 5 — Gate check before Phase 1

Do **not** launch the planning subagent until:

- [ ] Issue fetched and **Issue summary** produced
- [ ] Layers predicted from issue requirements
- [ ] Rules manifest built
- [ ] Every manifest file read in full this session
- [ ] **Rules loaded** block ready for the subagent prompt

## Phase 1 — Plan (delegated, read-only)

Launch a **Task** subagent (`subagent_type: generalPurpose`, `readonly: true`)
with `model` set to the resolved `plan-with` slug (default: `opus-high` →
`claude-opus-5-thinking-high`). **Do not use a max-effort variant.**

The plan phase writes **no code** — it produces the plan the Phase 2 agent follows.

**Plan agent prompt must include:**

- Full **Issue summary** and **Rules loaded** block from Phase 0
- Instruction to **re-read every rule file in the manifest** before planning
- Instruction to explore existing code (models, controllers, services, views,
  specs, routes) relevant to the issue and reuse established patterns
- **Read-only** — no file edits, no commits
- Plan must respect `development-principles.mdc`: vertical slices, TDD order,
  surgical scope, KISS/YAGNI, no premature abstraction
- Plan must respect layer SRP (`services.mdc`, `controllers.mdc`, `models.mdc`)
  and flag which layer each change belongs to
- Call out DB work explicitly: migrations via Docker, never hand-edit `db/schema.rb`
  (`rails-schema-via-migrations` skill, `migrations.mdc`)

**Plan output format:**

```text
## Implementation plan (#N)

### Approach
<2–5 sentences: chosen approach and why it fits project rules>

### Slices (in TDD order)
1. **<slice name>** — layer: <models|controllers|services|views|…>
   - Spec first: `spec/<path>_spec.rb` — <what it asserts>
   - Code: `app/<path>.rb` — <what changes>
   - Rule: <rule file governing this slice>
2. …

### Files to touch
| Path | Action | Why |
|------|--------|-----|

### Migrations
<none | migration name + columns/indexes, run via docker compose exec web bin/rails db:migrate>

### Tests
- RSpec: <which spec types, which acceptance criteria each covers>
- E2E needed? <yes/no + reason> (Phase 3 decides finally)

### Risks / open questions
- <risk or question needing user input>

### Out of scope
- <explicitly excluded work>
```

**You (orchestrator) after Phase 1:**

- Present the plan to the user
- If the plan surfaces **blocking open questions** (ambiguous requirements,
  conflicting rules, missing credentials/data), stop and ask before Phase 2
- Otherwise create the working branch ([Before Phase 2](#before-phase-2--create-the-branch)),
  then proceed to Phase 2, passing the plan verbatim

## Before Phase 2 — Create the branch

Create the working branch **after Phase 1** and **before any file edit** in
Phase 2 or Phase 3. Planning stays read-only. Code never lands on the default
branch.

**Skip** when the user asked for a plan only, or when Phase 1 has blocking
questions you have not resolved yet.

**Stay** on the current branch when it is already not the default branch
(`main`, `master`, or `defaultBranchRef` from `gh repo view`). Say which branch
you are using and continue.

**Create** a branch when `HEAD` is the default branch:

1. Type from the issue: `fix` for a bug, `feat` for a feature (labels or title).
   Use `chore` only when it is neither.
2. Slug: lowercase issue title, hyphens, about 3–5 words.
3. Name: `<type>/<issue-number>-<slug>` (example: `feat/436-subscription-due-notice`).
4. Create it from current `HEAD`:

```bash
git status
git checkout -b <type>/<issue-number>-<slug>
```

If that name already exists, check it out when it is this issue's branch. If it
exists and belongs to other work, stop and ask.

Do not commit in this step. Do not push. Phase 4 pushes only after `bin/ci` is
green. Phase 2 and Phase 3 must not switch branches and must not commit.

## Phase 2 — Implement (delegated)

Launch a **Task** subagent (`subagent_type: generalPurpose`) with `model` set to
the resolved `implement-with` slug (default: `grok-higher-fast` →
`cursor-grok-4.6-high-fast`). **Do not use a max-effort variant.**

**Implement agent prompt must include:**

- Full **Issue summary**, **Rules loaded** block, and the **Phase 1 plan**
- Instruction to **follow the plan** — deviate only when the plan proves wrong,
  and report the deviation
- Instruction to **re-read every rule file in the manifest** before editing code
- **TDD first** — failing **RSpec** before production code for new behavior
  (`development-principles.mdc`, `testing.mdc`). E2E (Playwright) is Phase 3.
- **Surgical scope** — implement only what the issue and plan cover; no drive-by refactors
- **Rails way** — MVC, REST, existing gestor patterns; services for business logic
- **Callbacks** — normalization only; side effects in services
- **Docker-only CLI** — `docker compose exec web` for Ruby/Rails/RSpec/RuboCop
  (`AGENTS.md`)
- **Migrations** — never hand-edit `db/schema.rb`; use
  `rails-schema-via-migrations` skill when touching the DB
- Run RuboCop on touched Ruby:
  `docker compose exec web bundle exec rubocop <paths>`
- Run relevant specs:
  `docker compose exec web bundle exec rspec <paths>`
- **Already on the working branch** from [Before Phase 2](#before-phase-2--create-the-branch).
  Do not create or switch branches. Do not commit. Phase 4 commits before the
  pull request

### Implementation order

1. Confirm `HEAD` is the working branch (not the default branch), then re-read
   the rules manifest and the Phase 1 plan
2. Work the plan slice by slice
3. Write failing RSpec examples for the slice's acceptance criteria (model,
   request, service, or policy specs — co-located with the layer changed)
4. Implement minimal production code to pass specs
5. Run RuboCop and RSpec; fix failures
6. Summarize what changed, which specs were added, plan deviations, and how it
   maps to the issue

### Quality bar

- Every new behavior has co-located specs (request/model/service as appropriate)
- Authorization via Pundit where controllers are touched (`policies.mdc`)
- No anti-patterns from `anti-patterns.mdc` (fat controllers, callback side effects)
- Valid, invalid, and edge paths covered in specs

**You (orchestrator) after Phase 2:**

- Summarize files changed (`git diff`, paths touched) and any plan deviations
- Map changes back to **Issue summary** acceptance criteria (done / partial / N/A)
- Note whether Phase 3 E2E is required (see criteria below) or can be skipped
- Proceed to Phase 3 unless E2E is clearly not applicable

## Phase 3 — E2E tests (delegated)

Run Phase 3 **after** Phase 2 completes. Launch a **Task** subagent
(`subagent_type: generalPurpose`) with `model` set to the resolved `e2e-with`
slug (default: `composer-2.5` → `composer-2.5-fast`). **Do not use a max-effort
variant.**

### When E2E is required

Create or extend Playwright specs when **any** of these apply:

- Issue changes **views**, **Hotwire/Turbo**, **Stimulus**, or customer/gestor/admin UI
- Acceptance criteria describe **user-visible** behavior (forms, navigation, flash,
  redirects, streams, toggles)
- New or changed **HTTP flows** that request specs alone cannot fully exercise
  (multi-step UI, JavaScript, infinite scroll, auth cookies)
- Issue labels or body mention E2E, Playwright, or browser testing
- The Phase 1 plan marked **E2E needed: yes**

### When E2E may be skipped

Skip Phase 3 only when **all** are true — document the skip reason in the report:

- Change is **backend-only** (model, service, job, query) with no UI surface
- Existing Playwright specs already cover the user flow (cite file paths)
- Issue acceptance criteria are fully met by RSpec alone

When uncertain, **write E2E** — UI regressions are expensive to catch later.

### E2E agent prompt must include

- Full **Issue summary**, **Rules loaded** block, Phase 1 plan, and Phase 2
  implementation summary
- List of files/routes/screens touched in Phase 2 (`git diff`)
- Instruction to read `AGENTS.md` (Playwright E2E best practices) and
  `.cursor/rules/testing.mdc`
- Study existing specs under `spec/e2e/` — match area helpers and patterns:
  - `spec/e2e/gestor/` + `gestor/helpers.js` — gestor store UI
  - `spec/e2e/admin/` + `admin/helpers.js` — admin namespace
  - `spec/e2e/*.spec.js` — customer/public app
  - `spec/e2e/helpers/` — shared utilities (`rails-runner.js`, `place-order.js`, etc.)
- **Playwright conventions** (from `AGENTS.md`):
  - Prefer `getByRole`, `getByLabel`, `getByPlaceholder`, `getByText`; avoid brittle CSS
  - Web-first assertions (`toBeVisible`, `toHaveURL`, `toContainText`)
  - No fixed `sleep` — rely on auto-waiting
  - One clear scenario per test; independent setup with unique data (stamps, slugs)
- **Hosts:** gestor `http://gestor.localhost:3031`, customer `http://app.localhost:3031`
  (E2E stack port 3031; dev is 3030)
- **Stay on the working branch.** Do not create or switch branches. Do not commit
  in this phase. Phase 4 commits before the pull request

### E2E workflow

1. Decide E2E required vs skip (justify in output)
2. If required: add or extend specs in `spec/e2e/` co-located with the area
   (e.g. gestor feature → `spec/e2e/gestor/gestor-<feature>.spec.js`)
3. Reuse auth helpers (`ensureGestorAuthState`, admin helpers) and `runRailsRunner`
   for seed data — do not duplicate login/seed logic
4. Start E2E stack if not running:
   ```bash
   make e2e-up
   ```
5. Run the new or affected specs:
   ```bash
   PLAYWRIGHT_BROWSERS_PATH=0 npm run test:e2e:docker:chromium -- spec/e2e/<path>.spec.js
   ```
   Or via Make: `make e2e-tests E2E_CONTEXT=gestor` / `customer` / `admin` when
   running a broader area.
6. Fix failing specs or implementation bugs surfaced by E2E; re-run until green
7. Summarize: specs added/changed, commands run, pass/fail per scenario

### E2E quality bar

- Specs assert **what the user sees or can do**, not internal implementation
- Cover happy path plus at least one error or edge path when the issue implies it
- Auth and role-specific flows use existing helper patterns
- Tests pass locally against the E2E Docker stack

**You (orchestrator) after Phase 3:**

- Merge plan, Phase 2, and Phase 3 into a final report
- Map all acceptance criteria: RSpec coverage + E2E coverage (or documented skip)
- List specs added (`spec/**/*.rb`, `spec/e2e/**/*.spec.js`)
- Note plan deviations, open questions, and follow-ups
- Continue to Phase 4 unless the user explicitly said not to open a PR

## Phase 4 — Pull request (CI-gated)

Run after Phase 3, or immediately on a PR-only request. **Read and follow
[pr.md](pr.md) in full** before committing, pushing, or calling `gh`.

If `HEAD` is still the default branch, stop and create the working branch
first ([Before Phase 2](#before-phase-2--create-the-branch)). Do not commit on
`main` or `master`.

Hard gates (also in `pr.md`):

- Commit uncommitted shippable work first. Never commit secrets.
- Run `bin/ci` from the repo root on the host. Do not wrap it in
  `docker compose exec web`. Do not pass `--native`.
- If `bin/ci` fails, stop. Do not push, do not open the PR, and do not fix CI
  unless the user asks.
- Push and `gh pr create` only after `bin/ci` exits 0.
- Link the Phase 0 issue with `Fixes #<N>` (or `Refs #<N>` when it must not
  auto-close) and comment the PR URL on the issue.
- Return the PR URL, base ← head, CI outcome, issue link, and whether a commit
  was created.

## Checklist

### Phase 0
- [ ] GitHub issue fetched with `gh issue view`
- [ ] Issue summary with requirements and acceptance criteria
- [ ] Layers predicted; rules manifest built
- [ ] Every manifest file read in full
- [ ] Gate passed before Phase 1

### Phase 1
- [ ] Plan produced by `plan-with` (default `opus-high`), read-only
- [ ] No max-effort model used
- [ ] Plan has slices in TDD order, files to touch, migrations, tests, risks
- [ ] Blocking open questions raised to the user before Phase 2

### Before Phase 2
- [ ] Working branch exists before any file edit
- [ ] Branch is not the default branch (`feat/<n>-…` or `fix/<n>-…`, or an existing non-default branch)
- [ ] No commit and no push in this step

### Phase 2
- [ ] Plan followed; deviations reported
- [ ] TDD: failing RSpec before production code
- [ ] Surgical scope — issue and plan only
- [ ] RuboCop clean on touched Ruby
- [ ] Relevant RSpec examples pass
- [ ] Changes map to acceptance criteria

### Phase 3
- [ ] E2E required vs skip decided (skip only with documented reason)
- [ ] Playwright specs added/extended when UI or user flows are touched
- [ ] Existing `spec/e2e/` helpers and patterns reused
- [ ] E2E stack up; affected specs pass (`npm run test:e2e:docker:chromium`)
- [ ] Acceptance criteria covered by RSpec + E2E (or justified skip)

### Phase 4
- [ ] `pr.md` followed
- [ ] Shippable work committed; secrets excluded
- [ ] `bin/ci` green before any push or `gh pr create`
- [ ] PR links the issue; PR URL commented on the issue
- [ ] PR URL returned to the user