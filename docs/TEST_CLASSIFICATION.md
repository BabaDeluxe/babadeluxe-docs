# 🧪 Testing Strategy & Classification Guide

This project maintains a strict separation of concerns in testing to ensure fast feedback loops and reliable deployments. We use specific file naming conventions to categorize tests by their scope and infrastructure requirements.

> Instead of .test.ts also .specs.ts can be used.

---

## 1. Unit Tests (`.unit.test.ts`)

**Scope:** Pure logic, algorithms, and individual functions/classes in complete isolation.

- **Dependencies:** All external dependencies (DB, API, File System) must be **mocked**.
- **Execution Speed:** Milliseconds.
- **Infrastructure:** None (no servers, no databases).

### ✅ Unit Test Litmus Test

> *"Can I run this test on a plane without WiFi and without starting a local database?"* -> **YES**

### Unit Test Examples

- **`rate-limit-tracker.unit.test.ts`**: Tests the token bucket algorithm with hardcoded time/requests.
- **`token-degradation.unit.test.ts`**: Tests retry logic by mocking the LLM provider to return specific error types.

---

## 2. Integration Tests (`.integration.test.ts`)

**Scope:** Component interaction and boundaries. Verifies that services, repositories, and external APIs talk to each other correctly.

- **Dependencies:**
  - **Database:** Real (e.g., SQLite `:memory:` or Dockerized DB).
  - **Network:** Real (Socket.IO client/server) or Recorded (Nock for external APIs).
- **Execution Speed:** Seconds.
- **Infrastructure:** Spins up limited test infrastructure.

### ✅ Integration Test Litmus Test

> *"Does this test require multiple parts of the system (e.g., Socket → Service → DB) to work together?"* -> **YES**

### Integration Test Examples

- **`settings.integration.test.ts`**: Spins up a Socket.IO server and in-memory DB to test real-time setting updates.
- **`llm-provider.integration.test.ts`**: Uses Nock to replay real HTTP traffic against LLM providers to verify API contract compliance.

---

## 3. Load Tests (`.load.test.ts`)

**Scope:** Performance, scalability, concurrency, and stability under stress.

- **Dependencies:** Full system stack (often against a staging-like environment).
- **Execution Speed:** Minutes.
- **Purpose:** Validate SLAs, rate limits, and race conditions.

### ✅ Load Test Litmus Test

> *"Am I testing what happens when 50 users do this at the exact same time?"* -> **YES**

### Load Test Examples

- **`chat.load.test.ts`**: Simulates 100 concurrent users to verify the rate limiter blocks the 11th request.
- **`chat-multi-user.load.test.ts`**: Verifies 50 Free vs. 50 Pro users competing for resources.

---

## 4. End-to-End Tests (`.e2e.test.ts`)

**Scope:** Complete user workflows through the full application stack from browser UI to backend services.

- **Dependencies:**
  - **Browser:** Real (Playwright/Puppeteer) running actual UI.
  - **Full Stack:** Backend server, database, external APIs, Socket.IO connections.
  - **Authentication:** Real login flows, session management.
- **Execution Speed:** Seconds to minutes per test.
- **Infrastructure:** Full production-like environment (can be staging or local).

### ✅ E2E Test Litmus Test

> *"Does this test simulate what an actual user does in their browser, clicking buttons and typing text?"* -> **YES**

### E2E Test Examples

- **`chat-message-flow.e2e.test.ts`**: User logs in, creates a chat, sends a message, receives AI response, and sees it rendered in the UI.
- **`subscription-upgrade.e2e.test.ts`**: Free user hits rate limit, clicks "Upgrade to Pro" button, completes Stripe checkout, and verifies Pro features unlock immediately.
- **`realtime-collaboration.e2e.test.ts`**: Two browser instances (User A edits message while User B watches) verify real-time updates appear correctly.

### Key Differences Between Integration and E2E Tests

| Aspect            | Integration Test                       | E2E Test                                        |
| ---------------- | -------------------------------------- | ---------------------------------------------- |
| **Entry Point**   | Service/Repository function            | Browser UI (button clicks, forms)              |
| **Assertion Target** | API responses, DB state            | Rendered DOM elements, visual feedback         |
| **User Simulation** | None                                | Full user journey (login → action → logout)    |
| **Flakiness Risk** | Low                                  | Higher (timing, animations, network)           |

### 🎯 E2E Best Practices for Babadeluxe

- **Use data-testid attributes** for stable selectors (avoid CSS classes that change).
- **Avoid hard waits** (`waitForTimeout`); use `waitFor({ state: 'visible' })` for real-time Socket.IO updates.
- **Test critical paths first**: Login → Create Chat → Send Message → Receive Response.
- **Mock external LLM providers** in E2E when testing UI logic, use real providers for smoke tests only.

---

## ⚡ Quick Decision Tree

1. **Is it testing what a user sees and clicks in a browser?**  
   👉 **E2E Test** (`.e2e.test.ts`)

2. **Is it testing concurrency or performance?**  
   👉 **Load Test** (`.load.test.ts`)

3. **Does it touch a real database, network, or start a server?**  
   👉 **Integration Test** (`.integration.test.ts`)

4. **Does it verify a specific logic flow using mocks for everything else?**  
   👉 **Unit Test** (`.unit.test.ts`)
