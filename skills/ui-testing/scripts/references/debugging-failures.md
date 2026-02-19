# Debugging UI Test Failures

## The Systematic Approach

**When a UI test fails, DON'T:**
- Immediately change the test
- Add random waits
- Change selectors blindly
- Blame "flaky tests"

**DO:**
1. Use `systematic-debugging` skill
2. Investigate root cause
3. Fix the actual problem
4. Verify fix works

## Common Failure Types

### 1. Element Not Found

**Symptoms:**
```
Error: Element '[data-testid="submit"]' not found
```

**Root Causes:**
- Feature removed/changed
- Selector changed
- Page not loaded yet
- Element hidden/not rendered

**Debug Steps:**
1. **Manually navigate to page**
2. **Check if element exists** (DevTools)
3. **Check selector is correct**
4. **Check timing** (is page loaded?)

**Fixes:**
```typescript
// If element changed
await tester.clickElement('[data-testid="new-submit-id"]');

// If timing issue
await tester.waitForElement('[data-testid="submit"]');
await tester.clickElement('[data-testid="submit"]');
```

### 2. Assertion Failures

**Symptoms:**
```
AssertionError: expected 'Hello' to contain 'Welcome'
```

**Root Causes:**
- Copy changed
- Feature behavior changed
- Wrong element selected
- Timing issue (asserting before update)

**Debug Steps:**
1. **What does page actually show?**
2. **Is assertion still valid?**
3. **Is feature behavior correct?**
4. **Screenshot the failure**

**Fixes:**
```typescript
// If copy changed (intentional)
await tester.assertTextContains('h1', 'New Welcome Message');

// If behavior changed (update test)
await tester.assertUrlContains('/new-dashboard');

// If timing issue
await tester.waitForElement('.success-message');
await tester.assertTextContains('.success-message', 'Success');
```

### 3. Flaky Tests

**Symptoms:**
- Test passes sometimes, fails others
- "Works locally, fails in CI"
- Timing-dependent failures

**Root Causes:**
- Race conditions
- Network timing
- Animation timing
- Hard-coded waits too short

**Debug Steps:**
1. **Run test 10 times** - Does it fail consistently?
2. **Check for hard-coded waits**
3. **Check for animations/transitions**
4. **Check network requests**

**Fixes:**
```typescript
// BAD - Hard-coded wait
await sleep(2000);
await tester.clickElement('#submit');

// GOOD - Wait for condition
await tester.waitForElement('#submit');
await tester.clickElement('#submit');

// BETTER - Playwright auto-waits
await tester.clickElement('#submit'); // Waits automatically

// For network
await tester.page.waitForLoadState('networkidle');
```

### 4. Timeout Errors

**Symptoms:**
```
TimeoutError: Waiting for element exceeded timeout of 10000ms
```

**Root Causes:**
- Element truly doesn't exist
- Selector wrong
- Page error preventing render
- Infinite loading state

**Debug Steps:**
1. **Does element appear manually?**
2. **Check browser console for errors**
3. **Check network tab for failed requests**
4. **Is selector correct?**

**Fixes:**
```typescript
// Increase timeout (last resort)
await tester.waitForElement('[data-testid="submit"]', 30000);

// Fix selector
await tester.waitForElement('[data-testid="correct-id"]');

// Add error checking
try {
  await tester.waitForElement('[data-testid="submit"]');
} catch (error) {
  // Check for error state
  const hasError = await tester.page.locator('.error-message').isVisible();
  if (hasError) {
    throw new Error('Page showed error instead of loading');
  }
  throw error;
}
```

### 5. Wrong Element Clicked

**Symptoms:**
- Test clicks wrong button
- Test fills wrong field
- Unexpected behavior

**Root Causes:**
- Multiple elements match selector
- Selector too generic
- z-index issues (element covered)

**Debug Steps:**
1. **Check selector uniqueness**
   ```typescript
   document.querySelectorAll('[data-testid="submit"]').length
   // Should be 1
   ```
2. **Check element visibility**
3. **Check z-index/overlay**

**Fixes:**
```typescript
// Make selector more specific
await tester.clickElement('form[data-testid="login"] button[data-testid="submit"]');

// Use nth-of-type (last resort)
await tester.clickElement('button[data-testid="submit"]:first-of-type');
```

## Debugging Tools

### 1. Playwright Inspector
```bash
cd ~/.gemini/skills/ui-testing/scripts
npx playwright test --debug
```
- Step through test
- Inspect selectors
- See what browser sees

### 2. Screenshots
```typescript
await tester.takeScreenshot('./debug-screenshot.png');
```
Auto-captures on failure if `screenshotOnFailure: true`

### 3. Browser DevTools
```typescript
// Pause test to inspect
await tester.page.pause();
```

### 4. Console Logging
```typescript
// Log element state
const text = await tester.page.locator('[data-testid="submit"]').textContent();
console.log('Button text:', text);

// Log page state
const url = tester.page.url();
console.log('Current URL:', url);
```

### 5. Network Inspection
```typescript
// Monitor network requests
await tester.page.route('**/*', route => {
  console.log('Request:', route.request().url());
  route.continue();
});
```

## Root Cause Analysis Checklist

When test fails:

- [ ] Can I reproduce failure manually?
- [ ] Does element exist on page?
- [ ] Is selector correct and unique?
- [ ] Are there console errors?
- [ ] Are there network errors?
- [ ] Did page structure change?
- [ ] Did feature behavior change?
- [ ] Is timing the issue?
- [ ] Does test pass locally but fail in CI?
- [ ] Is test truly flaky or is there a bug?

## Common Patterns

### Pattern 1: Wait for Element Before Interacting
```typescript
// Ensure element exists and is ready
await tester.waitForElement('[data-testid="submit"]');
await tester.clickElement('[data-testid="submit"]');
```

### Pattern 2: Wait for Network Before Assertion
```typescript
await tester.clickElement('[data-testid="submit"]');
await tester.page.waitForLoadState('networkidle');
await tester.assertUrlContains('/success');
```

### Pattern 3: Check Multiple Conditions
```typescript
// Wait for one of multiple possible outcomes
const locator1 = tester.page.locator('.success-message');
const locator2 = tester.page.locator('.error-message');

await Promise.race([
  locator1.waitFor(),
  locator2.waitFor()
]);

if (await locator1.isVisible()) {
  console.log('Success path');
} else if (await locator2.isVisible()) {
  console.log('Error path');
}
```

## When to Update Test vs Fix Code

### Update Test When:
- Feature intentionally changed
- Copy intentionally updated
- UI redesigned (new selectors)
- Test was wrong from start

### Fix Code When:
- Feature broken (regression)
- Bug introduced
- Element missing (should exist)
- Behavior different than spec

### Investigate Further When:
- Test flaky (sometimes passes)
- Different results locally vs CI
- Timing-dependent failures
- Can't reproduce manually

## Prevention

### 1. Use Stable Selectors
```typescript
// GOOD
await tester.clickElement('[data-testid="submit"]');

// BAD
await tester.clickElement('.css-xyz-123');
```

### 2. Avoid Hard-Coded Waits
```typescript
// BAD
await sleep(5000);

// GOOD
await tester.waitForElement('[data-testid="submit"]');
```

### 3. Test Edge Cases
```typescript
test('handles empty form submission', async () => {
  await tester.clickElement('[data-testid="submit"]');
  await tester.assertElementVisible('.error-message');
});
```

### 4. Run Tests Multiple Times
```bash
# Run test 10 times to catch flakiness
for i in {1..10}; do npm test login.test.ts; done
```

## Quick Reference

| Failure Type | First Check | Common Fix |
|-------------|-------------|------------|
| Element not found | Does element exist? | Update selector or wait |
| Assertion failed | What does page show? | Update assertion or fix feature |
| Flaky test | Run 10 times | Replace waits with conditions |
| Timeout | Is element truly there? | Fix selector or increase timeout |
| Wrong element | Is selector unique? | Make selector more specific |

**Remember:** Most "flaky tests" are actually bugs or timing issues. Fix root cause, don't work around.
