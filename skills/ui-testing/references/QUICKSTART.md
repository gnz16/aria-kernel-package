# Quick Start Guide - UI Testing Skill

## 🚀 5-Minute Setup

### 1. Activate the Skill

In Gemini CLI, simply say:
```
"Help me test a website"
"Create UI tests for a login page"
```

Gemini will automatically activate the `ui-testing` skill.

### 2. First-Time Installation

The skill will guide you, but if needed:
```bash
cd ~/.gemini/skills/ui-testing/scripts
npm install
npx playwright install chromium
```

## 📝 Quick Examples

### Example 1: Simple Login Test

```typescript
import { WebUITester } from './src/WebUITester.js';

const tester = new WebUITester({ headless: false });

try {
  await tester.init();
  
  await tester.navigateTo('https://example.com/login');
  await tester.enterText('#username', 'testuser');
  await tester.enterText('#password', 'password123');
  await tester.clickElement('#login-btn');
  
  await tester.assertUrlContains('/dashboard');
  await tester.assertElementVisible('.user-menu');
  
  console.log('✅ Login test passed!');
} finally {
  await tester.cleanup();
}
```

### Example 2: Test Suite

```typescript
import { MasterTestingSkill } from './src/MasterTestingSkill.js';

const master = new MasterTestingSkill();

master.createSuite('E-Commerce Tests')
  .addTest('Add to Cart', async (tester) => {
    await tester.navigateTo('https://shop.example.com');
    await tester.clickElement('.product:first-child .add-to-cart');
    await tester.assertTextContains('.cart-count', '1');
  })
  .addTest('Checkout', async (tester) => {
    await tester.navigateTo('https://shop.example.com/cart');
    await tester.clickElement('#checkout-btn');
    await tester.assertUrlContains('/checkout');
  })
  .build();

await master.executeAllTests();
```

## 🏃 Running Tests

```bash
cd ~/.gemini/skills/ui-testing/scripts

# Run all test suites
npm run master

# Run in parallel (faster!)
npm run master:parallel

# Run examples
npm run example:login
npm run example:workflow
```

## 📊 View Reports

After running tests, open:
```
~/.gemini/skills/ui-testing/scripts/test-results/report_*.html
```

## 💡 Common Commands

| Task | Command |
|------|---------|
| Navigate to URL | `await tester.navigateTo('https://...')` |
| Click button | `await tester.clickElement('#button-id')` |
| Enter text | `await tester.enterText('#input', 'text')` |
| Select dropdown | `await tester.selectDropdown('#select', 'Option')` |
| Check element exists | `await tester.assertElementExists('.class')` |
| Check text | `await tester.assertTextContains('h1', 'Welcome')` |
| Take screenshot | `await tester.takeScreenshot('./screenshot.png')` |

## 📚 Full Documentation

- [README.md](./README.md) - Complete framework docs
- [MASTER_SKILL_GUIDE.md](./MASTER_SKILL_GUIDE.md) - Advanced features
- Examples in `scripts/examples/`

## 🎯 Tips

1. Use `headless: false` during development to see the browser
2. Enable `screenshotOnFailure: true` for debugging
3. Use `data-testid` attributes for stable selectors
4. Run tests in parallel for large test suites
5. Check HTML reports for detailed results
