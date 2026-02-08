# Wobby's Universal Testing Standard (Pro Edition)

## 1. Core Philosophy

### Confidence > Coverage

We test to ship confidently, not to hit a percentage. If you have 100% coverage but are afraid to deploy on Friday, the tests failed. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)

### ROI (Return on Investment)

Every test has a cost (writing time, execution time, maintenance). Optimize for high-ROI tests:

- High ROI: Complex business logic, critical user journeys, edge cases that caused bugs before, cross-module interactions. [web](https://web.dev/articles/ta-strategies)
- Low ROI: Getters/setters, third-party framework code, testing typos through E2E.

### The Portfolio Shape: Testing Trophy

We follow the **Testing Trophy**: static + integration as the main focus, unit and E2E as supporting layers. [blog.cfischer](https://blog.cfischer.io/static-vs-unit-vs-integration-vs-e2e-testing-for-frontend-apps/)

1. Static analysis as the widest base.
2. Some unit tests for tricky logic.
3. Many integration tests (where most bugs live).
4. Few E2E tests for critical journeys.

Non-functional suites (load tests, fuzz tests, external dependency smoke tests) live **next to** this trophy and run on separate schedules. [testrail](https://www.testrail.com/blog/non-functional-testing/)

---

## 2. Glossary

| Term | Definition |
| :--- | :--- |
| SUT | System Under Test. The thing you're testing right now. |
| Deterministic | Always produces the same result for the same input. Tests must be deterministic. |
| Hermetic | Completely isolated. No shared state, cleans up after itself. |
| Mock | Fake replacement that verifies how it was called ("assert send() was called once"). |
| Stub | Fake replacement that returns canned data ("return { user: 'Bob' }"). |
| Fake | Simplified working implementation (in-memory DB, fake socket server). |
| Observable Behavior | What the code does from outside (return values, UI changes, API responses). Test this. |
| Implementation Detail | How the code works internally (private methods, variable names, log messages). Don't test this. |
| Contract | A promise: API schema, socket payload, DB record shape, public interface. Test this when it's part of your API.  [dev](https://dev.to/craftedwithintent/understanding-the-testing-pyramid-and-testing-trophy-tools-strategies-and-challenges-k1j) |
| Flaky Test | Passes sometimes, fails others without code changes. This is a bug. Fix or delete.  [thoughtbot](https://thoughtbot.com/blog/dealing-with-flaky-tests) |
| Smoke Test | Quick test to verify the system boots and critical functions work. |
| Regression | A bug that breaks a feature that used to work. |
| Coverage | % of code executed during tests. Useful for finding gaps, useless as a quality gate. |
| Load Test | Non-functional test to measure performance under expected or high load.  [sahipro](https://www.sahipro.com/post/performance-load-testing-strategy-best-practices) |
| Fuzz Test | Test that sends random or malformed input to find robustness and security issues.  [qodo](https://www.qodo.ai/glossary/fuzz-testing/) |

---

## 3. The Test Portfolio (Testing Trophy)

We follow the **Testing Trophy**: static + integration as the main investment, with unit and E2E as supporting layers. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)

### 🛡️ Layer 0: Static Analysis (Base)

- Tools: TypeScript, ESLint, Prettier.
- Run: Every save + pre-commit.
- Purpose: Catch typos, type errors, simple bugs before runtime. [blog.cfischer](https://blog.cfischer.io/static-vs-unit-vs-integration-vs-e2e-testing-for-frontend-apps/)
- Rule: If the type system or linter guarantees it, you don’t test it at runtime.

Optional boost: run mutation testing (e.g. Stryker) occasionally to check that your tests actually catch injected bugs, but keep this out of the main CI path. [marketplace.visualstudio](https://marketplace.visualstudio.com/items?itemName=stryker-mutator.stryker-mutator)

---

### 🧱 Layer 1: Unit Tests (Focused)

Scope: Single function, class, or module. Smallest code-level layer.

- Constraints: Millisecond-fast, no DB/network/filesystem, deterministic. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)
- Use for:
  - Complex business rules and algorithms.
  - Data transformations.
  - Validation logic and state machines.
  - Edge cases and error conditions.
- Avoid:
  - Private methods and internal names.
  - Framework internals.
  - Third-party behavior that the library already tests. [talent500](https://talent500.com/blog/fullstack-app-testing-unit-integration-e2e-2025/)

Think of unit tests as cheap sanity checks around tricky logic, not a religion.

---

### 🔗 Layer 2: Integration Tests (Workhorse)

Scope: Multiple units working together, or unit + real boundary.

This is where most of your test **budget** and confidence come from. [talent500](https://talent500.com/blog/fullstack-app-testing-unit-integration-e2e-2025/)

- Constraints:
  - Real code calls real code (mock only true external boundaries).
  - Prefer real DBs (ephemeral containers, in-memory fakes).
  - Still deterministic and repeatable.
- Use for:
  - API endpoints with real DB interactions.
  - Repository/service layers and transactions.
  - Component trees (parent + children, shared state).
  - Auth, session, and permission flows.
  - Message handlers, queues, and socket/event flows.
- Avoid:
  - Over-mocking your own internals (you want to catch wiring bugs).
  - Re-testing framework routing/middleware unless you added custom logic.

Trade-off: more cost than unit tests, but far better signal on real-world behavior. [blog.cfischer](https://blog.cfischer.io/static-vs-unit-vs-integration-vs-e2e-testing-for-frontend-apps/)

---

### 🚦 Layer 3: E2E / System Tests (Tip)

Scope: Entire app, from the user’s perspective, via real UI/HTTP. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)

- Constraints:
  - Slow and brittle by nature.
  - Keep to a very small set (3–5 critical journeys). [dev](https://dev.to/alex_aslam/testing-strategies-for-cicd-balancing-speed-depth-and-sanity-350e)
- Use for:
  - “Happy path” business flows (signup, purchase, critical CRUD).
  - Smoke checks (“does the system boot and load main screen?”).
  - Multi-service integration where lower levels can’t give full confidence. [talent500](https://talent500.com/blog/fullstack-app-testing-unit-integration-e2e-2025/)
- Avoid:
  - Exhaustive edge cases (do those at unit/integration).
  - Visual/layout details (padding, colors, pixel-perfect checks).
  - Micro-copy wording (unless it’s literally contractual).

Limit scope, run them in parallel, and treat E2E failures as high priority to keep the suite trustworthy. [dev](https://dev.to/alex_aslam/testing-strategies-for-cicd-balancing-speed-depth-and-sanity-350e)

---

## 4. Quality Gates & Speed Budgets

We use **time budgets** to keep feedback loops tight and CI sane. [umatechnology](https://umatechnology.org/best-practices-for-ci-cd-pipelines-on-a-budget/)

### Pre-Commit

Goal: Fast feedback while you’re in flow.

- Run:
  - Static analysis (TypeScript, ESLint, format check).
  - Targeted unit tests for changed files (or closest test groups).
- Budget: < 10 seconds on a typical dev machine.

If it’s slower, narrow the scope (only changed tests) or move more into PR CI. [umatechnology](https://umatechnology.org/best-practices-for-ci-cd-pipelines-on-a-budget/)

---

### PR / Main CI

Goal: High confidence on each merge without blocking for ages.

- Run:
  - Static analysis.
  - Full unit suite.
  - Integration tests (parallelized, DB via containers/fakes). [blog.cfischer](https://blog.cfischer.io/static-vs-unit-vs-integration-vs-e2e-testing-for-frontend-apps/)
- Budget: < 5 minutes total (use parallel runners, caching, and test selection). [shopify](https://shopify.engineering/test-budget-time-constrained-ci-feedback)

If you exceed budget, prioritize:

1. Most valuable tests first (critical paths, historically flaky areas). [shopify](https://shopify.engineering/test-budget-time-constrained-ci-feedback)
2. Defer heavy, low-value suites to scheduled/nightly runs.

---

### Release Gate

Goal: “Are we comfortable shipping this to real users?”

- Run:
  - Full suite: Unit + Integration + all E2E.
  - Critical non-functional checks (performance/load, external smoke). [sahipro](https://www.sahipro.com/post/performance-load-testing-strategy-best-practices)
- Functional budget: < 15 minutes (non-functional may run longer, e.g. pre-release jobs).

You can also add:

- Nightly or scheduled pipelines for heavy/regression suites.
- Manual exploratory testing for risky changes. [frugaltesting](https://www.frugaltesting.com/blog/a-complete-guide-to-building-effective-test-strategies-and-plans)

---

### Flaky Test Policy

Flaky tests destroy trust; they’re bugs in the test system. [thoughtbot](https://thoughtbot.com/blog/dealing-with-flaky-tests)

1. Quarantine immediately (tag/skip or move to a quarantine job) when a test flakes.
2. Assign an owner to triage within 24 hours:
   - Fast fix: race, timing, missing cleanup → fix now.
   - Infra/systemic: create a tracking issue and keep it quarantined until resolved.
3. If a test remains quarantined beyond an agreed window, delete or redesign it — no “permanent flaky” tests.
4. Retries are allowed only as a temporary band-aid while diagnosing, never as the final fix.

The objective: CI is either green and trustworthy, or red and worth stopping for. [minware](https://www.minware.com/guide/best-practices/flaky-test-quarantine)

---

## 5. What NOT to Test (The Anti-Patterns)

### ❌ Log Messages

Bad:

```ts
expect(console.log).toHaveBeenCalledWith('Processing started');
```

Why: Log messages change constantly and aren't user-facing behavior.

Exception: If logs are the feature (audit log API, compliance logging), test them as a contract.

---

### ❌ Internal Names (Classes, Props, Variables)

Bad:

```ts
expect(() => validate({})).toThrow(SuperDuperValidationError);
expect(wrapper.vm.isRunning).toBeDefined();
```

Why: Names are implementation details. Renaming breaks tests even though behavior is identical.

Good:

```ts
expect(() => validate({})).toThrow(/required field/i);
expect(wrapper.find('[data-loading]').exists()).toBe(true);
```

---

### ❌ Object Structure / Shape (Incidental)

Bad:

```ts
// Testing internal object keys you didn't promise to anyone
expect(result).toHaveProperty('id');
expect(result).toHaveProperty('name');
```

Why: Internal structure changes don't mean broken behavior.

Good:

```ts
// Test what you DO with it
const { id, name } = result;
expect(id).toBe('123');
expect(name).toBe('Alice');

// Or test the effect
const profileCard = render(ProfileCard, { user: result });
expect(profileCard.findByText('Alice')).toBeInTheDocument();
```

Exception (Contracts):  
DO test structure when it's a published contract that other code/teams/clients depend on:

```ts
// API response schema
test('GET /api/users returns correct schema', async () => {
  const response = await request(app).get('/api/users');
  expect(response.body).toMatchObject({
    users: expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(String),
        email: expect.any(String),
        role: expect.stringMatching(/^(admin|user)$/),
      })
    ])
  });
});
```

Rule: Only test shape when it's a promise you made (API docs, socket spec, persisted data format). [dev](https://dev.to/craftedwithintent/understanding-the-testing-pyramid-and-testing-trophy-tools-strategies-and-challenges-k1j)

---

### ❌ TypeScript Types at Runtime

Bad:

```ts
expect(typeof someFunction('hello')).toBe('string');
```

Why: TypeScript already proved this at compile time.

Exception: Runtime validation of user input (API payloads) with Zod/Yup is necessary.

---

### ❌ Third-Party Library Behavior

Bad:

```ts
const spy = vi.spyOn(got, 'get');
await fetchData();
expect(spy).toHaveBeenCalledWith('https://api.example.com/users');
```

Why: The library maintainers already test their own behavior.

Good:

```ts
// Mock the HTTP response, test YOUR logic
vi.mocked(got.get).mockResolvedValue({ 
  body: JSON.stringify([{ id: 1, name: 'Alice' }]) 
});

const result = await fetchUsers();
expect(result).toEqual([{ id: 1, name: 'Alice' }]);
```

---

### ❌ Framework Internals

Bad:

```ts
// Testing Vue reactivity
wrapper.vm.count = 5;
expect(wrapper.vm.count).toBe(5);
```

Why: Framework maintainers already test their reactivity/state systems.

Good:

```ts
// Test user-facing behavior
await wrapper.find('[data-testid="increment"]').trigger('click');
expect(wrapper.text()).toContain('Count: 1');
```

---

### ❌ CSS / Layout

Bad:

```ts
expect(getComputedStyle(button).padding).toBe('10px');
```

Why: CSS changes don't break functionality. Designers tweak padding constantly.

✅ Good (High ROI):  
Test conditional rendering and accessibility:

```ts
// Conditional rendering
test('shows error when validation fails', () => {
  const form = render(LoginForm);
  form.submit();
  expect(form.findByRole('alert').textContent).toContain('Email is required');
});

test('hides error when user starts typing', () => {
  const form = render(LoginForm);
  form.submit();
  expect(form.findByRole('alert')).toBeInTheDocument();
  
  form.findByLabel('Email').type('a');
  expect(form.queryByRole('alert')).not.toBeInTheDocument();
});
```

---

### ❌ Mock Interactions (Usually)

Bad:

```ts
const spy = vi.spyOn(logger, 'info');
processOrder(order);
expect(spy).toHaveBeenCalledWith('Order processed', { orderId: 123 });
```

Why: This tests how code works, not what it does. Refactoring breaks it.

Good:

```ts
await processOrder(order);
const savedOrder = await db.orders.findById(123);
expect(savedOrder.status).toBe('processed');
```

Exception (When the call is the behavior):

- Compliance/audit logging (regulatory requirements).
- Payment or external side-effect APIs where “we called it with X” is the contract.
- Side effects with no other observable output (email sends, analytics events).

Rule: If the interaction itself is the contract or regulatory requirement, test it; otherwise test observable outcomes.

---

### Summary: Test Behavior, Not Structure

Your test is bad if it breaks when you:

- Rename a variable/function/class.
- Change a log message.
- Reorder code.
- Switch libraries (but keep behavior).

→ Delete it.

Exception: If you changed a published contract (API schema, event payload), it's supposed to break — that's the test doing its job.

---

## 6. The Golden Rules

### 1. Refactoring Resistance

Tests must survive refactoring (changing structure without changing behavior).

Litmus test: Rename a private method → if tests break, they're brittle.

### 2. Test Observable Behavior & Contracts

Users don't care about your internal variable names or which class you throw. They care about:

- Does it return the right data?
- Does the UI show/hide correctly?
- Does it save to the database?

Contracts matter: If you document an API shape or socket payload, test it — breaking contracts breaks other teams. [web](https://web.dev/articles/ta-strategies)

### 3. Speed Budgets Drive Feedback Loops

- Pre-commit: < 10s (static + unit on changed code).
- PR check: < 5min (integration-heavy, parallelized).
- Release: Can be slower, but not hours. [shopify](https://shopify.engineering/test-budget-time-constrained-ci-feedback)

Slow tests → developers skip them → tests become worthless.

---

## 7. Non-Functional & Robustness Testing

These suites sit **alongside** the Testing Trophy. They validate performance, resilience, and dependency health, usually on scheduled or pre-release runs. [quashbugs](https://quashbugs.com/blog/non-functional-testing-guide)

### 7.1 Load / Performance Testing

Goal: Ensure the system behaves under realistic and peak load, and know your breaking points. [talent500](https://talent500.com/blog/performance-testing-strategies/)

- What:
  - Response times and latency under normal and peak load.
  - Throughput and error rates as concurrency increases.
  - Resource usage (CPU, memory, DB connections, disk I/O).
- Types:
  - Load testing: expected traffic patterns (daily peaks).
  - Stress testing: push beyond limits to find failure modes.
  - Spike testing: sudden bursts of traffic to test resilience. [goreplay](https://goreplay.org/blog/load-testing-strategies/)
- When:
  - Before major releases or big infra changes.
  - After significant query or architecture refactors.
  - On a scheduled basis for critical products.

Rule: Define clear SLOs (e.g. “p95 < 300ms up to N RPS”) and treat violations as release blockers or triggers for performance work. [adservio](https://www.adservio.fr/post/measuring-team-performance-with-slos-and-error-budgets)

---

### 7.2 Fuzz Testing

Goal: Break the system with malformed, random, or unexpected inputs to find robustness and security issues normal tests miss. [qodo](https://www.qodo.ai/glossary/fuzz-testing/)

- Targets:
  - Parsers (JSON, XML, CSV, file uploads).
  - Public APIs (especially internet-facing).
  - Critical workflows that handle untrusted input (web forms, webhooks, integrations).
- How:
  - Use coverage-guided fuzzers or library-specific fuzz tools where possible.
  - Log crashes, hangs, assertion failures, and unexpected responses.
  - For each confirmed issue, add a deterministic regression test in your normal suites. [github](https://github.com/resources/articles/what-is-fuzz-testing)
- When:
  - As background jobs (nightly/weekly).
  - After introducing new parsing/validation logic.
  - During security hardening work.

Rule: Fuzzing finds **classes** of bugs; your job is to turn each discovered bug into a normal test so it never comes back. [testgrid](https://testgrid.io/blog/fuzz-testing/)

---

### 7.3 External API Reachability & Smoke Tests

Goal: Quickly verify that **dependencies are reachable and core flows work** immediately after deploy (and over time). [oneuptime](https://oneuptime.com/blog/post/2026-01-25-smoke-testing-strategies/view)

This is distinct from:

- Health checks: basic liveness/readiness of your own service.
- Full E2E: deep user journeys.

#### Dependency / Connectivity Smoke

- Check that:
  - Your app boots and returns a basic response.
  - Core DB(s) can be connected to and simple queries succeed.
  - Critical external APIs (e.g. payments, auth, email) respond within a sane timeout. [testingxperts](https://www.testingxperts.com/blog/smoke-testing/)
- Classify dependencies:
  - `ok`: responding and within SLO.
  - `degraded`: slow or returning non-fatal errors.
  - `unreachable`: hard failure.
- Decide which dependencies are:
  - Hard requirements (block deploy / send 503).
  - Soft: app can run in degraded mode.

Example behavior (conceptual):

- `/smoke`:
  - Verifies app startup, DB connectivity, and 1–2 critical external integrations.
  - Returns 200 if core dependencies are healthy, 503 otherwise. [monoscope](https://monoscope.tech/blog/how-to-perform-an-api-health-check/)

#### How They Fit in Your Process

- After every deployment:
  - Run smoke tests automatically; on failure, alert and consider rollback. [ranorex](https://www.ranorex.com/blog/functional-and-nonfunctional-testing-explained/)
- On a schedule (prod monitoring):
  - Run smoke checks regularly from monitoring to catch outages early and alert on failures. [oneuptime](https://oneuptime.com/blog/post/2026-01-25-smoke-testing-strategies/view)

Rule: Smoke tests must be fast (ideally under 2 minutes total) and focused only on **high-risk, high-visibility** paths and key integrations. [opkey](https://www.opkey.com/blog/a-guide-to-different-types-of-software-testing)

---

## Adoption Checklist

### Phase 1 – This Week (Minimum Baseline)

- Static analysis is non‑negotiable:
  - [ ] TypeScript, ESLint, Prettier run clean before every commit. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)
- Unit tests for tricky logic only:
  - [ ] For any non-trivial business rule you touch, add/keep at least one unit test. [talent500](https://talent500.com/blog/fullstack-app-testing-unit-integration-e2e-2025/)
- One integration path per critical feature:
  - [ ] Each core feature (auth, main CRUD, main money flow) has at least one integration test hitting real DB or realistic fake. [blog.cfischer](https://blog.cfischer.io/static-vs-unit-vs-integration-vs-e2e-testing-for-frontend-apps/)
- CI gate:
  - [ ] Main CI runs static + unit + a **small** integration slice on every PR. [dev](https://dev.to/alex_aslam/testing-strategies-for-cicd-balancing-speed-depth-and-sanity-350e)

---

### Phase 2 – This Month (Solid Trophy Shape)

- Integration as workhorse:
  - [ ] For each critical API or service, there’s at least one happy-path integration test with real persistence. [kentcdodds](https://kentcdodds.com/blog/static-vs-unit-vs-integration-vs-e2e-tests)
  - [ ] Flaky tests are quarantined immediately and get an owner. [handbook.gitlab](https://handbook.gitlab.com/handbook/engineering/testing/quarantine-process/)
- E2E smoke:
  - [ ] 2–5 E2E tests exist for your top user journeys (e.g. login, main business flow, checkout). [dev](https://dev.to/alex_aslam/testing-strategies-for-cicd-balancing-speed-depth-and-sanity-350e)
- Speed budgets respected:
  - [ ] Pre-commit < 10s (static + focused unit). [umatechnology](https://umatechnology.org/best-practices-for-ci-cd-pipelines-on-a-budget/)
  - [ ] PR CI < 5min (parallelized, integration-heavy). [shopify](https://shopify.engineering/test-budget-time-constrained-ci-feedback)

---

### Phase 3 – Next 1–3 Months (Resilience & Non-Functional)

- Load / performance:
  - [ ] Define SLOs for at least one key flow (e.g. p95 latency, max RPS). [testrail](https://www.testrail.com/blog/non-functional-testing/)
  - [ ] Have at least one load test scenario that checks those SLOs before big releases. [kualitatem](https://www.kualitatem.com/blog/performance-testing/performance-testing-on-a-shoestring-budget-tips-and-tricks/)
- Fuzz / robustness:
  - [ ] Identify 1–3 high-risk input surfaces (parsers, public APIs, webhooks). [qodo](https://www.qodo.ai/glossary/fuzz-testing/)
  - [ ] Run a basic fuzzing setup against them and turn each found bug into a normal regression test. [github](https://github.com/resources/articles/what-is-fuzz-testing)
- External smoke:
  - [ ] Implement a smoke suite or endpoint that checks app boot, DB connectivity, and at least the most critical external API. [frugaltesting](https://www.frugaltesting.com/blog/smoke-testing-procedures-examples-and-best-practices)
  - [ ] Run this smoke check automatically after deploy and alert on failures. [testingxperts](https://www.testingxperts.com/blog/smoke-testing/)

---

### Phase 4 – Ongoing Habits

- Every bug is a test:
  - [ ] For each production bug, add one test at the cheapest layer that would have caught it.
- Keep the suite trustworthy:
  - [ ] No known flaky tests in the main CI path; anything flaky lives in quarantine or is deleted. [thoughtbot](https://thoughtbot.com/blog/dealing-with-flaky-tests)
- Review & prune:
  - [ ] Once per quarter, kill low-ROI tests and add missing high-ROI ones (based on incidents and near-misses). [learn.microsoft](https://learn.microsoft.com/en-us/dynamics365/guidance/implementation-guide/testing-strategy-checklist)
