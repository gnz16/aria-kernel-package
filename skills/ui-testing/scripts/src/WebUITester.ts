import { chromium, firefox, webkit, type Browser, type Page, type Locator } from 'playwright';
import { TestLogger } from './TestLogger.js';
import { TestWorkflow } from './TestWorkflow.js';
import { AIValidator } from './AIValidator.js';
import type { TesterConfig, SelectorType, AIValidationRequest } from './types.js';

/**
 * WebUITester - Main testing class
 * Automated Web UI Testing Framework using Playwright
 * Mirrors the C# Selenium implementation with modern async/await
 */
export class WebUITester {
    private browser: Browser | null = null;
    private page: Page | null = null;
    private logger: TestLogger;
    private validator: AIValidator;
    private config: Required<TesterConfig>;

    constructor(config: TesterConfig = {}) {
        this.config = {
            headless: config.headless ?? false,
            timeoutMs: config.timeoutMs ?? 10000,
            slowMo: config.slowMo ?? 0,
            viewport: config.viewport ?? { width: 1920, height: 1080 },
            browser: config.browser ?? 'chromium',
            recordVideo: config.recordVideo ?? false,
            screenshotOnFailure: config.screenshotOnFailure ?? true
        };

        this.logger = new TestLogger();
        this.validator = new AIValidator();
    }

    // ==================== LIFECYCLE METHODS ====================

    /**
     * Initialize the browser and create a new page
     */
    async init(): Promise<void> {
        this.logger.log(`Initializing ${this.config.browser} browser...`);

        const browserType = {
            chromium,
            firefox,
            webkit
        }[this.config.browser];

        this.browser = await browserType.launch({
            headless: this.config.headless,
            slowMo: this.config.slowMo
        });

        const context = await this.browser.newContext({
            viewport: this.config.viewport,
            recordVideo: this.config.recordVideo ? { dir: './test-results/videos' } : undefined
        });

        this.page = await context.newPage();
        this.page.setDefaultTimeout(this.config.timeoutMs);

        this.logger.logSuccess('Browser initialized');
    }

    /**
     * Close the browser and cleanup
     */
    async cleanup(): Promise<void> {
        this.logger.log('Cleaning up and closing browser...');

        if (this.page) {
            await this.page.close();
        }

        if (this.browser) {
            await this.browser.close();
        }

        this.logger.logSuccess('Cleanup complete');
    }

    // ==================== NAVIGATION METHODS ====================

    /**
     * Navigate to a URL
     */
    async navigateTo(url: string): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Navigating to: ${url}`);
        await this.page!.goto(url, { waitUntil: 'domcontentloaded' });
        this.logger.logSuccess(`Loaded: ${url}`);
    }

    /**
     * Go back in browser history
     */
    async goBack(): Promise<void> {
        this.ensureInitialized();
        this.logger.log('Navigating back');
        await this.page!.goBack();
    }

    /**
     * Go forward in browser history
     */
    async goForward(): Promise<void> {
        this.ensureInitialized();
        this.logger.log('Navigating forward');
        await this.page!.goForward();
    }

    /**
     * Reload the current page
     */
    async reload(): Promise<void> {
        this.ensureInitialized();
        this.logger.log('Reloading page');
        await this.page!.reload();
    }

    // ==================== INTERACTION METHODS ====================

    /**
     * Click an element
     */
    async clickElement(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Clicking element: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.click();
        this.logger.logSuccess(`Clicked: ${selector}`);
    }

    /**
     * Double click an element
     */
    async doubleClickElement(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Double clicking element: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.dblclick();
        this.logger.logSuccess(`Double clicked: ${selector}`);
    }

    /**
     * Right click an element
     */
    async rightClickElement(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Right clicking element: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.click({ button: 'right' });
        this.logger.logSuccess(`Right clicked: ${selector}`);
    }

    /**
     * Enter text into an input field
     */
    async enterText(selector: string, text: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Entering text into: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.clear();
        await element.fill(text);
        this.logger.logSuccess(`Entered text: "${text.substring(0, 20)}${text.length > 20 ? '...' : ''}"`);
    }

    /**
     * Select an option from a dropdown by visible text
     */
    async selectDropdown(selector: string, optionText: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Selecting option '${optionText}' from: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.selectOption({ label: optionText });
        this.logger.logSuccess(`Selected: ${optionText}`);
    }

    /**
     * Select an option from a dropdown by value
     */
    async selectDropdownByValue(selector: string, value: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Selecting value '${value}' from: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.selectOption({ value });
        this.logger.logSuccess(`Selected value: ${value}`);
    }

    /**
     * Hover over an element
     */
    async hoverElement(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Hovering over: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.hover();
        this.logger.logSuccess(`Hovered: ${selector}`);
    }

    /**
     * Check a checkbox or radio button
     */
    async check(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Checking: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.check();
        this.logger.logSuccess(`Checked: ${selector}`);
    }

    /**
     * Uncheck a checkbox
     */
    async uncheck(selector: string, type: SelectorType = 'css'): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Unchecking: ${selector}`);
        const element = await this.findElement(selector, type);
        await element.uncheck();
        this.logger.logSuccess(`Unchecked: ${selector}`);
    }

    // ==================== ASSERTION METHODS ====================

    /**
     * Assert that an element exists in the DOM
     */
    async assertElementExists(selector: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        try {
            await this.findElement(selector, type);
            this.logger.logSuccess(`Element exists: ${selector}`);
            return true;
        } catch (error) {
            this.logger.logError(`Element not found: ${selector}`);
            return false;
        }
    }

    /**
     * Assert that text exactly matches
     */
    async assertTextEquals(selector: string, expectedText: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const actualText = await element.textContent() || '';
        const matches = actualText.trim() === expectedText.trim();

        if (matches) {
            this.logger.logSuccess(`Text matches: "${expectedText}"`);
        } else {
            this.logger.logError(`Text mismatch. Expected: "${expectedText}", Got: "${actualText}"`);
        }

        return matches;
    }

    /**
     * Assert that text contains a substring
     */
    async assertTextContains(selector: string, expectedSubstring: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const actualText = await element.textContent() || '';
        const contains = actualText.includes(expectedSubstring);

        if (contains) {
            this.logger.logSuccess(`Text contains: "${expectedSubstring}"`);
        } else {
            this.logger.logError(`Text doesn't contain: "${expectedSubstring}". Actual: "${actualText}"`);
        }

        return contains;
    }

    /**
     * Assert that the URL contains a specific part
     */
    async assertUrlContains(expectedUrlPart: string): Promise<boolean> {
        this.ensureInitialized();
        const currentUrl = this.page!.url();
        const contains = currentUrl.includes(expectedUrlPart);

        if (contains) {
            this.logger.logSuccess(`URL contains: "${expectedUrlPart}"`);
        } else {
            this.logger.logError(`URL doesn't contain: "${expectedUrlPart}". Current URL: "${currentUrl}"`);
        }

        return contains;
    }

    /**
     * Assert that the URL equals exactly
     */
    async assertUrlEquals(expectedUrl: string): Promise<boolean> {
        this.ensureInitialized();
        const currentUrl = this.page!.url();
        const matches = currentUrl === expectedUrl;

        if (matches) {
            this.logger.logSuccess(`URL matches: "${expectedUrl}"`);
        } else {
            this.logger.logError(`URL mismatch. Expected: "${expectedUrl}", Got: "${currentUrl}"`);
        }

        return matches;
    }

    /**
     * Assert that an element is visible
     */
    async assertElementVisible(selector: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const isVisible = await element.isVisible();

        if (isVisible) {
            this.logger.logSuccess(`Element is visible: ${selector}`);
        } else {
            this.logger.logError(`Element is not visible: ${selector}`);
        }

        return isVisible;
    }

    /**
     * Assert that an element is enabled
     */
    async assertElementEnabled(selector: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const isEnabled = await element.isEnabled();

        if (isEnabled) {
            this.logger.logSuccess(`Element is enabled: ${selector}`);
        } else {
            this.logger.logError(`Element is disabled: ${selector}`);
        }

        return isEnabled;
    }

    /**
     * Assert that an element is checked
     */
    async assertElementChecked(selector: string, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const isChecked = await element.isChecked();

        if (isChecked) {
            this.logger.logSuccess(`Element is checked: ${selector}`);
        } else {
            this.logger.logError(`Element is not checked: ${selector}`);
        }

        return isChecked;
    }

    /**
     * Assert count of elements matching selector
     */
    async assertElementCount(selector: string, expectedCount: number, type: SelectorType = 'css'): Promise<boolean> {
        this.ensureInitialized();
        const elements = await this.page!.locator(this.buildSelector(selector, type)).all();
        const actualCount = elements.length;
        const matches = actualCount === expectedCount;

        if (matches) {
            this.logger.logSuccess(`Element count matches: ${expectedCount}`);
        } else {
            this.logger.logError(`Element count mismatch. Expected: ${expectedCount}, Got: ${actualCount}`);
        }

        return matches;
    }

    // ==================== AI VALIDATION METHODS ====================

    /**
     * Use AI validation for complex scenarios
     * Example: Validating if a complex UI state "looks correct"
     */
    async validateWithPrompt(validationPrompt: string, context?: string): Promise<boolean> {
        this.ensureInitialized();
        const screenshot = await this.takeScreenshot();
        const pageContext = context || await this.getPageContext();

        const request: AIValidationRequest = {
            prompt: validationPrompt,
            screenshot,
            context: pageContext,
            timestamp: new Date()
        };

        this.logger.log(`Using AI validation: ${validationPrompt}`);
        const result = await this.validator.validate(request);

        if (result.passed) {
            this.logger.logSuccess(`AI validation passed: ${result.reason || 'No reason provided'}`);
        } else {
            this.logger.logError(`AI validation failed: ${result.reason || 'No reason provided'}`);
        }

        return result.passed;
    }

    /**
     * Validate dynamic content with AI
     */
    async validateDynamicContent(
        selector: string,
        validationCriteria: string,
        type: SelectorType = 'css'
    ): Promise<boolean> {
        this.ensureInitialized();
        const element = await this.findElement(selector, type);
        const content = await element.textContent() || '';

        const prompt = `Validate if the following content meets this criteria: '${validationCriteria}'\nContent: ${content}\nRespond with only 'PASS' or 'FAIL: reason'`;

        this.logger.log('Validating dynamic content with AI');
        const result = await this.validator.validateText(prompt, content);

        if (result.passed) {
            this.logger.logSuccess('Dynamic content validation passed');
        } else {
            this.logger.logError(`Dynamic content validation failed: ${result.reason}`);
        }

        return result.passed;
    }

    // ==================== WORKFLOW METHODS ====================

    /**
     * Create a new test workflow
     */
    createWorkflow(workflowName: string): TestWorkflow {
        this.logger.log(`Creating workflow: ${workflowName}`);
        return new TestWorkflow(workflowName, this.logger);
    }

    // ==================== UTILITY METHODS ====================

    /**
     * Execute JavaScript in the page context
     */
    async executeScript<T>(script: string): Promise<T> {
        this.ensureInitialized();
        this.logger.log('Executing JavaScript');
        return await this.page!.evaluate(script) as T;
    }

    /**
     * Wait for a specific number of seconds
     */
    async waitForSeconds(seconds: number): Promise<void> {
        this.logger.log(`Waiting for ${seconds} seconds`);
        await this.page!.waitForTimeout(seconds * 1000);
    }

    /**
     * Wait for an element to appear
     */
    async waitForElement(selector: string, type: SelectorType = 'css', timeoutMs?: number): Promise<void> {
        this.ensureInitialized();
        this.logger.log(`Waiting for element: ${selector}`);
        const builtSelector = this.buildSelector(selector, type);
        await this.page!.waitForSelector(builtSelector, {
            timeout: timeoutMs || this.config.timeoutMs,
            state: 'visible'
        });
        this.logger.logSuccess(`Element appeared: ${selector}`);
    }

    /**
     * Wait for navigation to complete
     */
    async waitForNavigation(): Promise<void> {
        this.ensureInitialized();
        this.logger.log('Waiting for navigation');
        await this.page!.waitForLoadState('networkidle');
    }

    /**
     * Take a screenshot
     */
    async takeScreenshot(path?: string): Promise<string> {
        this.ensureInitialized();
        const screenshot = await this.page!.screenshot({
            path,
            fullPage: true,
            type: 'png'
        });

        if (path) {
            this.logger.log(`Screenshot saved: ${path}`);
        }

        return screenshot.toString('base64');
    }

    /**
     * Get page title
     */
    async getTitle(): Promise<string> {
        this.ensureInitialized();
        return await this.page!.title();
    }

    /**
     * Get current URL
     */
    getCurrentUrl(): string {
        this.ensureInitialized();
        return this.page!.url();
    }

    /**
     * Get logger instance
     */
    getLogger(): TestLogger {
        return this.logger;
    }

    /**
     * Get page instance (for advanced usage)
     */
    getPage(): Page {
        this.ensureInitialized();
        return this.page!;
    }

    // ==================== PRIVATE HELPER METHODS ====================

    /**
     * Find an element using the specified selector type
     */
    private async findElement(selector: string, type: SelectorType): Promise<Locator> {
        this.ensureInitialized();
        const builtSelector = this.buildSelector(selector, type);
        return this.page!.locator(builtSelector).first();
    }

    /**
     * Build selector string based on type
     */
    private buildSelector(selector: string, type: SelectorType): string {
        switch (type) {
            case 'css':
                return selector;
            case 'xpath':
                return `xpath=${selector}`;
            case 'text':
                return `text=${selector}`;
            case 'id':
                return `#${selector}`;
            case 'data-testid':
                return `[data-testid="${selector}"]`;
            case 'role':
                return `role=${selector}`;
            default:
                return selector;
        }
    }

    /**
     * Get page context for logging/validation
     */
    private async getPageContext(): Promise<string> {
        this.ensureInitialized();
        const title = await this.page!.title();
        const url = this.page!.url();
        const bodyText = await this.page!.locator('body').textContent() || '';

        return `Title: ${title}\nURL: ${url}\nVisible Text (first 500 chars): ${bodyText.substring(0, 500)}`;
    }

    /**
     * Ensure browser is initialized
     */
    private ensureInitialized(): void {
        if (!this.browser || !this.page) {
            throw new Error('Browser not initialized. Call init() first.');
        }
    }
}
