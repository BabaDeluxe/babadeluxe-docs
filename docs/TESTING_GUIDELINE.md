# Wobby's Universal Testing Standard (Pro Edition)

## 1. Core Philosophy

### Confidence > Coverage

We test to ship confidently, not to hit a percentage. If you have 100% coverage but are afraid to deploy on Friday, the tests failed.

### ROI (Return on Investment)

Every test has a cost (writing time, execution time, maintenance). Optimize for high-ROI tests:

- **High ROI:** Complex business logic, critical user journeys, edge cases that caused bugs before.
- **Low ROI:** Getters/setters, third-party framework code, testing typos through E2E.

### The Portfolio Shape (Pyramid/Trophy)

1. **Many** fast, isolated tests (Unit).
2. **Some** realistic, connected tests (Integration) — *where most bugs live.*
3. **Few** slow, broad tests (E2E).

***

## 2. Glossary

| Term | Definition |
| :--- | :--- |
| **SUT** | **System Under Test**. The thing you're testing right now. |
| **Deterministic** | Always produces the same result for the same input. Tests must be deterministic. |
| **Hermetic** | Completely isolated. No shared state, cleans up after itself. |
| **Mock** | Fake replacement that verifies *how* it was called ("assert send() was called once"). |
| **Stub** | Fake replacement that returns canned data ("return { user: 'Bob' }"). |
| **Fake** | Simplified working implementation (in-memory DB, fake socket server). |
| **Observable Behavior** | What the code *does* from outside (return values, UI changes, API responses). **Test this.** |
| **Implementation Detail** | How the code works internally (private methods, variable names, log messages). **Don't test this.** |
| **Contract** | A promise to other code/teams/users: API schema, socket payload, DB record shape, public interface. **Test this when it's part of your API.** |
| **Flaky Test** | Passes sometimes, fails others without code changes. This is a bug. Fix or delete. |
| **Smoke Test** | Quick test to verify the system boots and basic functions work. |
| **Regression** | A bug that breaks a feature that used to work. |
| **Coverage** | % of code executed during tests. Useful for finding gaps, useless as a quality gate. |

***

## 3. The Test Portfolio

### 🛡️ Layer 0: Static Analysis

Tools: TypeScript, ESLint, Prettier*

**Run:** On every save + pre-commit.

**Purpose:** Catch typos, type errors, syntax mistakes instantly.

**Rule:** Never write a runtime test for something the type checker guarantees.

***

### 🧱 Layer 1: Unit Tests

*Scope: Single function, class, or module.*

**Constraints:**

- Fast (milliseconds)
- Isolated (no DB, no network, no filesystem)
- Deterministic (same input = same output, always)

**What to test:**

- Pure business logic
- Algorithms and data transformations
- Validation rules
- State machines
- Edge cases and error conditions

**What NOT to test:**

- Private methods
- Framework internals
- Third-party library behavior

***

### 🔗 Layer 2: Integration Tests

*Scope: Multiple units working together, or unit + real boundary.*

**Constraints:**

- Sociable (real code calls real code; only mock external boundaries)
- Use real databases (ephemeral/test containers)
- Still deterministic

**What to test:**

- API endpoints with real DB
- Database queries and transactions
- Component interactions (parent + child)
- Socket/event handlers with real boundaries
- Authentication/authorization flows

**What NOT to test:**

- Your own function calls (don't mock internal code)
- Framework routing/middleware (unless you wrote custom logic)

***

### 🚦 Layer 3: E2E / System Tests

*Scope: Entire application, user's perspective.*

**Constraints:**

- Expensive (slow, brittle)
- Keep count low (3-5 critical journeys max)

**What to test:**

- Critical user journeys ("Login → Buy → Checkout")
- Smoke tests ("Does it boot?")
- Multi-service integration (if microservices)

**What NOT to test:**

- Validation edge cases (do this in Unit)
- Error message wording (do this in Integration)
- Every possible user flow

***

## 4. Quality Gates & Policies

### Pre-Commit Hook

Static checks + Unit tests (changed files only)
Budget: < 10 seconds

### PR / CI Check

Static checks + Full Unit suite + Integration tests
Budget: < 5 minutes

### Release Gate

Full suite (Unit + Integration + E2E)
Budget: < 15 minutes
Zero flaky tests allowed

### Flake Policy: Zero Tolerance

1. If a test flakes, **Quarantine** it immediately (disable).
2. Assign owner to fix within 24 hours.
3. If not fixed, **delete it**. A flaky test is worse than no test.
4. Never use retries as a "solution"—only as a temporary bandaid while fixing.

***

## 5. What NOT to Test (The Anti-Patterns)

### ❌ Log Messages

**Bad:**

```ts
expect(console.log).toHaveBeenCalledWith('Processing started');
```

**Why:** Log messages change constantly and aren't user-facing behavior.

**Exception:** If logs are the feature (audit log API), test them.

***

### ❌ Internal Names (Classes, Props, Variables)

**Bad:**

```ts
expect(() => validate({})).toThrow(SuperDuperValidationError);
expect(wrapper.vm.isRunning).toBeDefined();
```

**Why:** Names are implementation details. Renaming breaks tests even though behavior is identical.

**Good:**

```ts
expect(() => validate({})).toThrow(/required field/i);
expect(wrapper.find('[data-loading]').exists()).toBe(true);
```

***

### ❌ Object Structure / Shape (Incidental)

**Bad:**

```ts
// Testing internal object keys you didn't promise to anyone
expect(result).toHaveProperty('id');
expect(result).toHaveProperty('name');
```

**Why:** Internal structure changes don't mean broken behavior.

**Good:**

```ts
// Test what you DO with it
const { id, name } = result;
expect(id).toBe('123');
expect(name).toBe('Alice');

// Or test the effect
const profileCard = render(ProfileCard, { user: result });
expect(profileCard.findByText('Alice')).toBeInTheDocument();
```

**Exception (Contracts):**
DO test structure when it's a **published contract** that other code/teams/clients depend on:

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

// Socket event payload schema
test('user.updated event matches contract', () => {
  const payload = { id: '123', name: 'Alice', updatedAt: '2026-02-06' };
  expect(() => UserUpdatedSchema.parse(payload)).not.toThrow();
});
```

**Rule:** Only test shape when it's a promise you made (API docs, socket spec, persisted data format).

***

### ❌ TypeScript Types at Runtime

**Bad:**

```ts
expect(typeof someFunction('hello')).toBe('string');
```

**Why:** TypeScript already proved this at compile time.

**Exception:** Runtime validation of user input (API payloads) with Zod/Yup is necessary.

***

### ❌ Third-Party Library Behavior

**Bad:**

```ts
const spy = vi.spyOn(got, 'get');
await fetchData();
expect(spy).toHaveBeenCalledWith('https://api.example.com/users');
```

**Why:** The `got` maintainers already test `got`.

**Good:**

```ts
// Mock the HTTP response, test YOUR logic
vi.mocked(got.get).mockResolvedValue({ 
  body: JSON.stringify([{ id: 1, name: 'Alice' }]) 
});

const result = await fetchUsers();
expect(result).toEqual([{ id: 1, name: 'Alice' }]);
```

***

### ❌ Framework Internals

**Bad:**

```ts
// Testing Vue reactivity
wrapper.vm.count = 5;
expect(wrapper.vm.count).toBe(5);
```

**Why:** Framework maintainers already test their reactivity/state systems.

**Good:**

```ts
// Test user-facing behavior
await wrapper.find('[data-testid="increment"]').trigger('click');
expect(wrapper.text()).toContain('Count: 1');
```

***

### ❌ CSS / Layout

**Bad:**

```ts
expect(getComputedStyle(button).padding).toBe('10px');
```

**Why:** CSS changes don't break functionality. Designers tweak padding constantly.

**✅ Good (High ROI):**
Test **conditional rendering** and **accessibility**:

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

test('shows premium features only for paid users', () => {
  const dashboard = render(Dashboard, { user: { isPremium: true } });
  expect(dashboard.findByText('Advanced Analytics')).toBeInTheDocument();
  
  const freeDashboard = render(Dashboard, { user: { isPremium: false } });
  expect(freeDashboard.queryByText('Advanced Analytics')).not.toBeInTheDocument();
});

// Accessibility
test('submit button is disabled when loading', () => {
  const form = render(LoginForm, { isLoading: true });
  expect(form.findByRole('button', { name: /submit/i })).toBeDisabled();
});
```

**Why conditional rendering is gold:**

- Catches real bugs (error never shows, spinner never hides)
- Survives refactoring (change CSS/component structure without breaking tests)
- Documents UI contracts (`v-if`, `*ngIf`, `{condition && <Component />}`)

***

### ❌ Mock Interactions

**Bad:**

```ts
const spy = vi.spyOn(logger, 'info');
processOrder(order);
expect(spy).toHaveBeenCalledWith('Order processed', { orderId: 123 });
```

**Why:** Testing *how* code works, not *what* it does. Refactoring breaks this.

**Good:**

```ts
await processOrder(order);
const savedOrder = await db.orders.findById(123);
expect(savedOrder.status).toBe('processed');
```

***

### Summary: Test Behavior, Not Structure

Your test is bad if it breaks when you:

- Rename a variable/function/class
- Change a log message
- Reorder code
- Switch libraries (but keep behavior)

**→ Delete it.**

**Exception:** If you changed a **published contract** (API schema, event payload), it's *supposed* to break—that's the test doing its job.

***

## 6. The Golden Rules

### 1. Refactoring Resistance

Tests must survive refactoring (changing structure without changing behavior).

**Litmus test:** Rename a private method → if tests break, they're brittle.

***

### 2. Test Observable Behavior & Contracts

Users don't care about your internal variable names or which class you throw. They care about:

- Does it return the right data?
- Does the UI show/hide correctly?
- Does it save to the database?

**Contracts matter:** If you document an API shape or socket payload, test it—breaking contracts breaks other teams.

***

### 3. Speed Budgets Drive Feedback Loops

- **Pre-commit:** < 10s (static + unit)
- **PR check:** < 5min (integration)
- **Release:** Can be slower, but not hours

Slow tests = developers skip them = tests become worthless.

***

**Done.** This is the final, pro-grade version with the contract/incidental-structure distinction baked in.
