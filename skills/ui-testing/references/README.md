# UI Testing System

A modern, powerful UI testing framework built with **Playwright** and **TypeScript**. Designed for minimal token usage with coded logic for common scenarios and optional AI validation for complex cases.

## 🌟 NEW: Master Testing Skill

The framework now includes an **advanced orchestration layer** for enterprise-grade test management:

- ✅ **Test Suite Management** - Organize tests into logical suites with priorities
- ✅ **Parallel Execution** - Run tests concurrently for 4x faster execution  
- ✅ **Comprehensive Reporting** - Beautiful HTML reports + JSON for CI/CD
- ✅ **Retry Logic** - Automatic retry of failed tests
- ✅ **AI Token Tracking** - Monitor and optimize AI validation costs
- ✅ **Screenshot on Failure** - Automatic failure documentation

**[📖 Master Skill Guide](./MASTER_SKILL_GUIDE.md)** | **[🎯 Quick Start](#master-skill-quick-start)**

---

## ✨ Features

- 🎯 **Simple API** - Clean, intuitive methods for all common testing scenarios
- 🚀 **Modern Stack** - TypeScript + Playwright for reliability and performance
- 🌐 **Multi-Browser** - Support for Chromium, Firefox, and WebKit
- 🔄 **Workflow Builder** - Chain multiple test steps with ease
- 📊 **Rich Logging** - Colored console output with timestamps
- 📸 **Screenshots & Videos** - Built-in screenshot and video recording
- 🤖 **AI Validation** - Optional AI-powered validation for complex scenarios
- ⚡ **Auto-Waiting** - Playwright's built-in smart waiting reduces flaky tests

## 📦 Installation

```bash
# Navigate to the project directory
cd ui-testing-system

# Install dependencies
npm install

# Install Playwright browsers
npx playwright install
```

## 🚀 Quick Start

### Basic Test Example

```typescript
import { WebUITester } from './src/WebUITester.js';

async function simpleTest() {
  const tester = new WebUITester({ headless: false });
  
  try {
    await tester.init();
    
    // Navigate and interact
    await tester.navigateTo('https://example.com');
    await tester.enterText('#username', 'testuser');
    await tester.clickElement('#submit');
    
    // Assertions
    await tester.assertUrlContains('/dashboard');
    await tester.assertTextContains('h1', 'Welcome');
    
  } finally {
    await tester.cleanup();
  }
}

simpleTest();
```

### Master Skill Quick Start

```typescript
import { MasterTestingSkill } from './src/MasterTestingSkill.js';

const master = new MasterTestingSkill();

// Create test suites
master.createSuite('Login Tests')
  .addTest('Valid Login', async (tester) => {
    await tester.navigateTo('https://example.com/login');
    await tester.enterText('#email', 'user@test.com');
    await tester.clickElement('#login-btn');
    await tester.assertUrlContains('/dashboard');
  })
  .build();

// Execute all with comprehensive reporting
await master.executeAllTests();

// Or run in parallel
await master.executeParallel(4);
```

**[Full Master Skill Documentation →](./MASTER_SKILL_GUIDE.md)**

### Workflow Example

```typescript
const workflow = tester.createWorkflow('Login Flow')
  .addStep(async () => await tester.navigateTo('https://example.com'))
  .addStep(async () => await tester.enterText('#email', 'user@example.com'))
  .addStep(async () => await tester.enterText('#password', 'password123'))
  .addStep(async () => await tester.clickElement('#login-button'))
  .addStep(async () => await tester.assertUrlContains('/dashboard'));

await workflow.execute();
```

## 📖 API Reference

### Configuration

```typescript
const tester = new WebUITester({
  headless: false,           // Show browser window
  timeoutMs: 10000,          // Default timeout
  slowMo: 100,               // Slow down operations (ms)
  browser: 'chromium',       // 'chromium' | 'firefox' | 'webkit'
  recordVideo: false,        // Record test execution
  screenshotOnFailure: true  // Auto-screenshot on errors
});
```

### Navigation Methods

| Method | Description |
|--------|-------------|
| `navigateTo(url)` | Navigate to a URL |
| `goBack()` | Go back in history |
| `goForward()` | Go forward in history |
| `reload()` | Reload current page |
| `waitForNavigation()` | Wait for navigation to complete |

### Interaction Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `clickElement(selector, type?)` | selector: string, type?: SelectorType | Click an element |
| `doubleClickElement(selector, type?)` | selector: string, type?: SelectorType | Double click an element |
| `rightClickElement(selector, type?)` | selector: string, type?: SelectorType | Right click an element |
| `enterText(selector, text, type?)` | selector: string, text: string, type?: SelectorType | Enter text into input |
| `selectDropdown(selector, optionText, type?)` | selector: string, optionText: string, type?: SelectorType | Select by visible text |
| `selectDropdownByValue(selector, value, type?)` | selector: string, value: string, type?: SelectorType | Select by value |
| `hoverElement(selector, type?)` | selector: string, type?: SelectorType | Hover over element |
| `check(selector, type?)` | selector: string, type?: SelectorType | Check checkbox/radio |
| `uncheck(selector, type?)` | selector: string, type?: SelectorType | Uncheck checkbox |

### Assertion Methods

All assertion methods return `Promise<boolean>` and log results automatically.

| Method | Description |
|--------|-------------|
| `assertElementExists(selector, type?)` | Assert element exists in DOM |
| `assertTextEquals(selector, expectedText, type?)` | Assert exact text match |
| `assertTextContains(selector, substring, type?)` | Assert text contains substring |
| `assertUrlContains(urlPart)` | Assert URL contains string |
| `assertUrlEquals(url)` | Assert exact URL match |
| `assertElementVisible(selector, type?)` | Assert element is visible |
| `assertElementEnabled(selector, type?)` | Assert element is enabled |
| `assertElementChecked(selector, type?)` | Assert element is checked |
| `assertElementCount(selector, count, type?)` | Assert number of matching elements |

### Utility Methods

| Method | Description |
|--------|-------------|
| `waitForSeconds(seconds)` | Wait for specified seconds |
| `waitForElement(selector, type?, timeout?)` | Wait for element to appear |
| `executeScript<T>(script)` | Execute JavaScript in page |
| `takeScreenshot(path?)` | Take screenshot (returns base64) |
| `getTitle()` | Get page title |
| `getCurrentUrl()` | Get current URL |
| `getLogger()` | Access logger instance |
| `getPage()` | Get Playwright Page instance |

### Selector Types

```typescript
type SelectorType = 'css' | 'xpath' | 'text' | 'id' | 'data-testid' | 'role';

// Examples:
await tester.clickElement('#submit', 'css');           // CSS selector
await tester.clickElement('//button', 'xpath');        // XPath
await tester.clickElement('Click me', 'text');         // Text content
await tester.clickElement('submit-btn', 'id');         // ID (adds # automatically)
await tester.clickElement('login-button', 'data-testid'); // data-testid attribute
await tester.clickElement('button', 'role');           // ARIA role
```

### AI Validation (Optional)

For complex scenarios that can't be validated with coded logic:

```typescript
// Validate overall page state
await tester.validateWithPrompt(
  'Does the dashboard appear correctly loaded with all widgets visible?'
);

// Validate dynamic content
await tester.validateDynamicContent(
  '.news-headline',
  'Is this headline relevant to technology?'
);
```

> **Note:** AI validation requires implementing the `AIValidator` class with your preferred AI API (OpenAI, Anthropic, etc.)

## 🏃 Running Examples

### Basic Examples

```bash
# Run login test
npm run example:login

# Run workflow test
npm run example:workflow

# Run advanced features test
npm run example:advanced
```

### Master Skill Examples

```bash
# Run all test suites sequentially
npm run master

# Run all test suites in parallel
npm run master:parallel

# Run specific suite
npm run master:suite "Login & Authentication"

# Run specific test
npm run master:test "Valid Login"
```

## 📁 Project Structure

```
ui-testing-system/
├── src/
│   ├── WebUITester.ts      # Main testing class
│   ├── TestLogger.ts        # Logging with colors
│   ├── TestWorkflow.ts      # Workflow builder
│   ├── AIValidator.ts       # AI validation (optional)
│   └── types.ts             # TypeScript definitions
├── examples/
│   ├── login-test.ts        # Basic login example
│   ├── form-workflow-test.ts # Workflow example
│   └── advanced-test.ts     # Advanced features
├── test-results/            # Screenshots, videos, logs
├── package.json
├── tsconfig.json
└── README.md
```

## 🎯 Best Practices

1. **Use Coded Logic First** - Only use AI validation when coded assertions can't handle the scenario
2. **Leverage Workflows** - Break complex tests into reusable workflow steps
3. **Smart Selectors** - Use `data-testid` attributes for stable selectors
4. **Auto-Waiting** - Trust Playwright's auto-waiting instead of manual waits
5. **Screenshot on Failure** - Always capture screenshots when tests fail
6. **Consistent Cleanup** - Always call `cleanup()` in `finally` block

## 🔧 Advanced Usage

### Custom Timeouts

```typescript
// Per-element timeout
await tester.waitForElement('#slow-loader', 'css', 30000);

// Global timeout configuration
const tester = new WebUITester({ timeoutMs: 30000 });
```

### Taking Screenshots

```typescript
// Save to file
await tester.takeScreenshot('./screenshots/test-result.png');

// Get base64 string
const base64 = await tester.takeScreenshot();
```

### Accessing Playwright Page

For advanced scenarios not covered by the framework:

```typescript
const page = tester.getPage();
await page.evaluate(() => console.log('Direct Playwright access'));
```

### Saving Logs

```typescript
// Save logs to file
tester.getLogger().saveToFile('./logs/test-run.log');

// Get logs programmatically
const logs = tester.getLogger().getLogs();
```

## 🐛 Debugging

```typescript
// Run with visible browser
const tester = new WebUITester({ headless: false });

// Slow down operations
const tester = new WebUITester({ slowMo: 500 });

// Record video
const tester = new WebUITester({ recordVideo: true });
```

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! This framework is designed to be:
- Simple and intuitive
- Reliable with minimal flaky tests
- Efficient with minimal resource usage
- Extensible for custom needs

---

Built with ❤️ using Playwright and TypeScript
