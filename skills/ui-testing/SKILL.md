---
name: ui-testing
description: Enterprise-grade web UI testing framework with Playwright, TDD enforcement, systematic debugging integration, suite management, parallel execution, and comprehensive reporting. Use for browser automation, E2E testing, and test-driven UI development. Triggers on UI testing tasks, form validation, authentication flows, and user journey testing.
license: MIT
metadata:
  author: custom
  version: "2.0.0"
---

# UI Testing Skill

You are an expert in automated web UI testing using the modern Playwright framework with TypeScript. This skill provides enterprise-grade testing capabilities with intelligent test orchestration, TDD enforcement, systematic debugging, parallel execution, and comprehensive reporting.

## The Iron Law

```
NO UI TESTS WITHOUT WATCHING THEM FAIL FIRST
```

If you didn't see the test fail, you don't know if it tests the right thing.

**Test passed immediately?** You're testing existing behavior or wrong thing. Fix test.

## When to Use This Skill

### ALWAYS Use For:
- **E2E User Flows** - Complete user journeys
- **Critical Business Paths** - Checkout, payments, signup
- **Form Submissions** - Contact forms, registrations
- **Authentication Flows** - Login, logout, permissions
- **Test-Driven UI Development** - Write tests before implementation

### Use When Requested:
- Component testing
- Visual regression testing
- Accessibility testing
- Performance testing
- Cross-browser testing

### DON'T Use For:
- Unit tests (use `test-driven-development` skill)
- API tests (use backend testing)
- Pure logic tests (not UI-related)
- Database tests

## Framework Capabilities

### Core Testing (WebUITester)
- **Navigation**: `navigateTo()`, `goBack()`, `goForward()`, `reload()`
- **Interactions**: `clickElement()`, `enterText()`, `selectDropdown()`, `hoverElement()`, `check()`, `uncheck()`
- **Assertions**: `assertElementExists()`, `assertTextEquals()`, `assertUrlContains()`, `assertElementVisible()`
- **Utilities**: `waitForElement()`, `takeScreenshot()`, `executeScript()`

### Master Testing Skill (Orchestration)
- **Test Suite Management**: Organize tests with priorities and tags
- **Parallel Execution**: Run tests 4x faster with concurrent execution
- **Retry Logic**: Automatic retry of failed tests (configurable)
- **Comprehensive Reporting**: Beautiful HTML reports + JSON for CI/CD
- **AI Token Tracking**: Monitor AI validation usage
- **Screenshot on Failure**: Automatic failure documentation

## Priority-Based Test Categories

| Priority | Category | Tests | Impact |
|----------|----------|-------|--------|
| **CRITICAL** | Authentication & Authorization | Login, logout, permissions, password reset | Business-critical |
| **CRITICAL** | Payment & Checkout | Cart, payment, order completion | Revenue impact |
| **HIGH** | Core User Flows | Registration, search, navigation | User experience |
| **HIGH** | Form Submissions | Contact, feedback, data entry | Data integrity |
| **MEDIUM** | UI Components | Modals, dropdowns, tabs, accordions | Functionality |
| **MEDIUM** | Navigation | Menu, breadcrumbs, pagination | Usability |
| **LOW** | Visual Regression | Layout, styling, responsiveness | Polish |
| **LOW** | Edge Cases** | Error states, empty states | Robustness |

Focus on CRITICAL and HIGH priority tests first.

## Integration with Test-Driven Development

**When writing UI features, follow TDD RED-GREEN-REFACTOR cycle:**

### RED - Write Failing UI Test
```typescript
test('user can submit contact form', async () => {
  await tester.navigateTo('https://example.com/contact');
  await tester.enterText('#name', 'John Doe');
  await tester.enterText('#email', 'john@example.com');
  await tester.enterText('#message', 'Hello!');
  await tester.clickElement('#submit');
  await tester.assertTextContains('.success', 'Thank you');
});
```

### Verify RED - Watch Browser Fail
```bash
cd ~/.gemini/skills/ui-testing/scripts
npm test contact-form.test.ts
```
Confirm test fails because feature doesn't exist yet.

### GREEN - Implement UI Feature
Build the contact form UI with submission logic.

### Verify GREEN - Watch Test Pass
Run test again - should pass now.

### REFACTOR - Improve Test/Code
Extract helpers, improve selectors, clean up code.

**Use with `test-driven-development` skill for complete TDD workflow.**

## Integration with Systematic Debugging

**When UI tests fail, DON'T immediately change the test:**

1. **Use `systematic-debugging` skill**
2. **Investigate root cause:**
   - Is feature broken? (fix feature)
   - Is selector broken? (UI changed, update test)
   - Is test flaky? (add proper waits)
   - Is assertion wrong? (fix test logic)
3. **Reproduce failure manually**
4. **Fix the actual issue**
5. **Verify test passes**

**Never fix test without understanding why it failed.**

## Setup Instructions

The skill is self-contained at `~/.gemini/skills/ui-testing/scripts/`

### First-Time Setup
```bash
cd ~/.gemini/skills/ui-testing/scripts
npm install
npx playwright install chromium
```

**Note**: Only run setup once. The installation persists across sessions.

## Usage Patterns

### Pattern 1: TDD UI Development

```typescript
// 1. RED - Write failing test
test('user can login', async () => {
  await tester.navigateTo('https://app.com/login');
  await tester.enterText('#email', 'user@test.com');
  await tester.enterText('#password', 'password123');
  await tester.clickElement('#login-btn');
  await tester.assertUrlContains('/dashboard');
});

// 2. Verify RED - watch it fail
// 3. GREEN - implement login UI
// 4. Verify GREEN - watch it pass
// 5. REFACTOR - improve code/test
```

### Pattern 2: Test Suite with Priorities

```typescript
import { MasterTestingSkill } from './src/MasterTestingSkill.js';

const master = new MasterTestingSkill();

master.createSuite('Critical - Authentication')
  .withDescription('Login/logout flows')
  .withPriority(10) // CRITICAL
  .addTest('Valid Login', async (tester) => {
    // Test implementation
  })
  .addTest('Invalid Login', async (tester) => {
    // Test implementation
  })
  .build();

master.createSuite('High - User Profile')
  .withPriority(8) // HIGH
  .addTest('Update Profile', async (tester) => {
    // Test implementation
  })
  .build();

await master.executeAllTests(); // Runs by priority
```

### Pattern 3: Parallel Execution

```typescript
// Run all test suites in parallel (4 threads)
await master.executeParallel(4);
```

## Testing Anti-Patterns

### ❌ BAD Practices

```typescript
// BAD: Testing implementation details
await tester.assertElementExists('.css-class-xyz-123');

// BAD: Hard-coded waits (flaky)
await sleep(5000);
await tester.clickElement('#button');

// BAD: Overly specific selectors
await tester.clickElement('div > div > div:nth-child(3) > button.submit');

// BAD: Testing multiple things
test('login and profile and settings work', async () => {
  // Too much in one test
});

// BAD: Mocking everything
const mockBrowser = { /* everything mocked */ };
```

### ✅ GOOD Practices

```typescript
// GOOD: Test user-facing attributes
await tester.clickElement('[data-testid="submit-button"]');

// GOOD: Use Playwright auto-waiting
await tester.clickElement('#button'); // Waits automatically

// GOOD: Semantic selectors
await tester.clickElement('button[type="submit"]', 'Submit');

// GOOD: One thing per test
test('user can login', async () => {
  // Only tests login
});

// GOOD: Test real browser
const tester = new WebUITester(); // Real Playwright
```

## Selector Strategies

**Priority order (best to worst):**

1. **data-testid** (stable, semantic)
   ```typescript
   await tester.clickElement('[data-testid="login-button"]');
   ```

2. **ARIA attributes** (accessibility + testing)
   ```typescript
   await tester.clickElement('[aria-label="Submit form"]');
   ```

3. **Text content** (user-facing)
   ```typescript
   await tester.clickElement('Submit', 'text');
   ```

4. **ID attributes** (if stable)
   ```typescript
   await tester.clickElement('#submit', 'id');
   ```

5. **CSS selectors** (last resort, brittle)
   ```typescript
   await tester.clickElement('.btn-primary');
   ```

**Never use:**
- Implementation class names (.css-xyz-123)
- nth-child selectors
- Deep nesting (div > div > div > button)

## Test Quality Checklist

Before marking tests complete:

- [ ] Test name describes user action/expectation clearly
- [ ] Watched test FAIL before implementing feature (TDD)
- [ ] Test uses user-facing selectors (data-testid, ARIA, text)
- [ ] Test is independent (can run alone, any order)
- [ ] No hard-coded waits (uses Playwright auto-waiting)
- [ ] Screenshot on failure enabled
- [ ] Test passes consistently (run 3 times minimum)
- [ ] Edge cases covered (empty states, errors, validation)
- [ ] Test fast (< 30 seconds for unit, < 2 min for E2E)
- [ ] Test documents expected behavior clearly

Can't check all boxes? Test needs improvement.

## Red Flags - STOP and Reconsider

If you catch yourself thinking:

- "Skip watching test fail, I'll just write it" → **STOP. Follow TDD.**
- "Add sleep(5000) to make it work" → **STOP. Use proper waits.**
- "Test passed immediately" → **STOP. Testing wrong thing.**
- "Mock the entire browser" → **STOP. Test real behavior.**
- "Test implementation details" → **STOP. Test user behavior.**
- "Similar test already failed 3 times" → **STOP. Flaky test - fix root cause.**
- "Just change assertion to make it pass" → **STOP. Test failure has meaning.**
- "Skip test, manually verified it works" → **STOP. Manual ≠ reliable.**

**ALL of these mean: Return to TDD/debugging principles.**

## Running Tests

```bash
cd ~/.gemini/skills/ui-testing/scripts

# Run all test suites sequentially
npm run master

# Run all test suites in parallel
npm run master:parallel

# Run specific suite
npm run master:suite "Suite Name"

# Run specific test
npm run master:test "Test Name"

# Run basic examples
npm run example:login
npm run example:workflow
npm run example:advanced
```

## Test Configuration

Configuration file: `~/.gemini/skills/ui-testing/scripts/test-config.json`

Key settings:
- `browserType`: 'chromium' | 'firefox' | 'webkit'
- `headless`: true/false (show browser window)
- `timeout`: Default timeout in milliseconds
- `retryFailedTests`: Enable automatic retry
- `maxRetries`: Number of retry attempts (max 2)
- `screenshotOnFailure`: Capture screenshots on failure
- `parallelExecution`: Enable parallel execution
- `reportPath`: Where to save reports

## Reporting

After test execution, reports are generated at:
- **HTML Report**: `~/.gemini/skills/ui-testing/scripts/test-results/report_TIMESTAMP.html`
- **JSON Report**: `~/.gemini/skills/ui-testing/scripts/test-results/report_TIMESTAMP.json`
- **Screenshots**: `~/.gemini/skills/ui-testing/scripts/test-results/screenshots/`

## Supporting Techniques

This skill integrates with:

- **test-driven-development** - Write UI tests first (RED-GREEN-REFACTOR)
- **systematic-debugging** - Debug test failures systematically
- **react-best-practices** - Test React components optimally
- **web-design-guidelines** - Accessibility-first testing (ARIA attributes)
- **verification-before-completion** - Ensure tests actually work

**Reference documents in `references/`:**
- `README.md` - Complete framework documentation
- `MASTER_SKILL_GUIDE.md` - Advanced orchestration
- `QUICKSTART.md` - Quick start guide

## Common Test Patterns

### Authentication Flow
```typescript
await tester.navigateTo('https://app.com/login');
await tester.enterText('[data-testid="email-input"]', 'user@test.com');
await tester.enterText('[data-testid="password-input"]', 'password123');
await tester.clickElement('[data-testid="login-button"]');
await tester.assertUrlContains('/dashboard');
await tester.assertElementVisible('[data-testid="user-menu"]');
```

### Form Submission
```typescript
await tester.enterText('#name', 'John Doe');
await tester.enterText('#email', 'john@example.com');
await tester.selectDropdown('#country', 'United States');
await tester.check('#terms-checkbox');
await tester.clickElement('#submit');
await tester.assertTextContains('.success', 'Thank you');
```

### Error Handling
```typescript
await tester.enterText('#email', 'invalid-email');
await tester.clickElement('#submit');
await tester.assertElementVisible('.error-message');
await tester.assertTextContains('.error-message', 'valid email');
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple UI breaks. Test takes 2 minutes. |
| "I'll test after implementing" | Tests passing immediately prove nothing. |
| "Already manually tested" | Manual ≠ systematic. Can't re-run. |
| "Test is flaky, skip it" | Flaky test = symptom of problem. Fix root cause. |
| "Hard-coded wait fixes it" | Hides timing issue. Use proper waits. |
| "Mock everything for speed" | Fast tests that don't test reality = useless. |
| "Test implementation, not behavior" | Implementation changes, behavior shouldn't. |

## Best Practices

1. **Test user behavior, not implementation**
2. **Use data-testid or ARIA attributes for selectors**
3. **Write tests before implementing (TDD)**
4. **Watch tests fail before coding (verify test works)**
5. **Use Playwright's auto-waiting (no sleeps)**
6. **Keep tests independent (run in any order)**
7. **One assertion per test when possible**
8. **Screenshot failures automatically**
9. **Run tests in parallel for speed**
10. **Use systematic debugging for failures**

## Notes

- Framework uses **Playwright** (more reliable than Selenium)
- Auto-waiting is built-in (reduces flaky tests)
- Cross-browser support (Chromium, Firefox, WebKit)
- TypeScript provides full type safety
- All examples are executable and tested
- Integrates with TDD and debugging workflows
- Priority-based execution ensures critical paths tested first
