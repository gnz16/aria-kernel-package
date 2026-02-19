import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { dirname } from 'path';
import chalk from 'chalk';
import { WebUITester } from './WebUITester.js';
import { TestSuiteManager } from './TestSuiteManager.js';
import { ReportGenerator } from './ReportGenerator.js';
import { AITokenOptimizer } from './AITokenOptimizer.js';
import { TestSuiteBuilder } from './TestSuiteBuilder.js';
import type {
    TestConfiguration,
    TestSuite,
    TestCase,
    TestResult,
    TestSuiteResult,
    MasterTestReport,
    TestStatus
} from './types.js';

/**
 * MasterTestingSkill - Orchestrates all testing capabilities
 * Manages test suites, configurations, reporting, and AI token optimization
 * Mirrors the C# MasterTestingSkill functionality
 */
export class MasterTestingSkill {
    private config: TestConfiguration;
    private suiteManager: TestSuiteManager;
    private reportGenerator: ReportGenerator;
    private tokenOptimizer: AITokenOptimizer;

    constructor(configPath: string = 'test-config.json') {
        this.config = this.loadConfiguration(configPath);
        this.suiteManager = new TestSuiteManager();
        this.reportGenerator = new ReportGenerator();
        this.tokenOptimizer = new AITokenOptimizer();
    }

    // ==================== MAIN EXECUTION METHODS ====================

    /**
     * Execute all registered test suites with intelligent token management
     */
    async executeAllTests(): Promise<MasterTestReport> {
        console.log(chalk.cyan('╔════════════════════════════════════════════════╗'));
        console.log(chalk.cyan('║   MASTER WEB UI TESTING SKILL - EXECUTION      ║'));
        console.log(chalk.cyan('╚════════════════════════════════════════════════╝\n'));

        const report: MasterTestReport = {
            startTime: new Date(),
            endTime: new Date(),
            configuration: this.config,
            suiteResults: [],
            totalTests: 0,
            passedTests: 0,
            failedTests: 0,
            skippedTests: 0,
            passRate: 0,
            duration: 0
        };

        const suites = this.suiteManager.getAllSuites();

        for (const suite of suites) {
            console.log(chalk.blue(`\n▶ Executing Suite: ${suite.name}`));
            console.log(chalk.gray(`  Priority: ${suite.priority} | Tests: ${suite.tests.length}`));

            const suiteResult = await this.executeSuite(suite);
            report.suiteResults.push(suiteResult);
        }

        report.endTime = new Date();
        this.calculateStatistics(report);

        this.reportGenerator.generateReport(report);
        this.tokenOptimizer.printUsageReport();

        return report;
    }

    /**
     * Execute specific test suite by name
     */
    async executeSuiteByName(suiteName: string): Promise<TestSuiteResult> {
        const suite = this.suiteManager.getSuite(suiteName);
        if (!suite) {
            throw new Error(`Suite '${suiteName}' not found`);
        }
        return await this.executeSuite(suite);
    }

    /**
     * Execute a single test by name
     */
    async executeTest(testName: string): Promise<TestResult> {
        const test = this.suiteManager.findTest(testName);
        if (!test) {
            throw new Error(`Test '${testName}' not found`);
        }
        return await this.executeSingleTest(test);
    }

    /**
     * Execute tests in parallel for faster execution
     */
    async executeParallel(maxThreads: number = 4): Promise<MasterTestReport> {
        console.log(chalk.yellow(`▶ Parallel Execution Mode: ${maxThreads} threads\n`));

        const report: MasterTestReport = {
            startTime: new Date(),
            endTime: new Date(),
            configuration: this.config,
            suiteResults: [],
            totalTests: 0,
            passedTests: 0,
            failedTests: 0,
            skippedTests: 0,
            passRate: 0,
            duration: 0
        };

        const suites = this.suiteManager.getAllSuites();

        // Execute suites in parallel using Promise.all with concurrency limit
        const results = await this.executeWithConcurrencyLimit(
            suites,
            async (suite) => await this.executeSuite(suite),
            maxThreads
        );

        report.suiteResults = results;
        report.endTime = new Date();
        this.calculateStatistics(report);

        this.reportGenerator.generateReport(report);
        this.tokenOptimizer.printUsageReport();

        return report;
    }

    // ==================== TEST SUITE REGISTRATION ====================

    /**
     * Register a new test suite
     */
    registerSuite(suite: TestSuite): void {
        this.suiteManager.addSuite(suite);
        console.log(chalk.green(`✓ Registered Suite: ${suite.name} (${suite.tests.length} tests)`));
    }

    /**
     * Build test suite fluently
     */
    createSuite(name: string): TestSuiteBuilder {
        return new TestSuiteBuilder(name, this);
    }

    // ==================== CONFIGURATION MANAGEMENT ====================

    /**
     * Load configuration from file or use defaults
     */
    private loadConfiguration(path: string): TestConfiguration {
        if (existsSync(path)) {
            const json = readFileSync(path, 'utf-8');
            return JSON.parse(json);
        }

        // Default configuration
        return {
            browserType: 'chromium',
            headless: false,
            timeout: 10000,
            retryFailedTests: true,
            maxRetries: 2,
            screenshotOnFailure: true,
            videoRecording: false,
            aiValidationEnabled: true,
            tokenBudget: 10000,
            parallelExecution: false,
            maxParallelThreads: 4,
            reportFormat: 'HTML',
            reportPath: './test-results'
        };
    }

    /**
     * Save current configuration to file
     */
    saveConfiguration(path: string): void {
        const json = JSON.stringify(this.config, null, 2);
        mkdirSync(dirname(path), { recursive: true });
        writeFileSync(path, json, 'utf-8');
        console.log(chalk.green(`✓ Configuration saved to: ${path}`));
    }

    /**
     * Get current configuration
     */
    getConfiguration(): TestConfiguration {
        return { ...this.config };
    }

    /**
     * Update configuration
     */
    updateConfiguration(updates: Partial<TestConfiguration>): void {
        this.config = { ...this.config, ...updates };
    }

    // ==================== PRIVATE EXECUTION LOGIC ====================

    /**
     * Execute a complete test suite
     */
    private async executeSuite(suite: TestSuite): Promise<TestSuiteResult> {
        const result: TestSuiteResult = {
            suiteName: suite.name,
            startTime: new Date(),
            endTime: new Date(),
            testResults: [],
            passedCount: 0,
            failedCount: 0,
            duration: 0
        };

        const sortedTests = suite.tests.sort((a, b) => a.priority - b.priority);

        for (const test of sortedTests) {
            const testResult = await this.executeSingleTest(test);
            result.testResults.push(testResult);

            if (testResult.status === 'FAILED' && suite.stopOnFailure) {
                console.log(chalk.yellow(`  ⚠ Stopping suite '${suite.name}' due to failure`));
                break;
            }
        }

        result.endTime = new Date();
        result.passedCount = result.testResults.filter(r => r.status === 'PASSED').length;
        result.failedCount = result.testResults.filter(r => r.status === 'FAILED').length;
        result.duration = result.endTime.getTime() - result.startTime.getTime();

        return result;
    }

    /**
     * Execute a single test with retry logic
     */
    private async executeSingleTest(test: TestCase): Promise<TestResult> {
        const result: TestResult = {
            testName: test.name,
            startTime: new Date(),
            endTime: new Date(),
            status: 'FAILED' as TestStatus,
            message: '',
            attempts: 0,
            duration: 0
        };

        let tester: WebUITester | null = null;
        let attempts = 0;
        let passed = false;

        while (attempts <= this.config.maxRetries && !passed) {
            attempts++;

            if (attempts > 1) {
                console.log(chalk.yellow(`  ↻ Retry attempt ${attempts} for: ${test.name}`));
            }

            try {
                tester = new WebUITester({
                    headless: this.config.headless,
                    timeoutMs: this.config.timeout,
                    browser: this.config.browserType,
                    recordVideo: this.config.videoRecording,
                    screenshotOnFailure: this.config.screenshotOnFailure
                });

                await tester.init();

                // Execute test with token optimization
                this.tokenOptimizer.beginTest(test.name);
                await test.action(tester);
                this.tokenOptimizer.endTest();

                result.status = 'PASSED' as TestStatus;
                result.message = 'Test completed successfully';
                passed = true;

                console.log(chalk.green(`  ✓ PASSED: ${test.name}`));

            } catch (error: any) {
                result.status = 'FAILED' as TestStatus;
                result.message = error.message;
                result.stackTrace = error.stack;

                console.log(chalk.red(`  ✗ FAILED: ${test.name}`));
                console.log(chalk.red(`    Error: ${error.message}`));

                if (this.config.screenshotOnFailure && tester) {
                    result.screenshotPath = await this.captureFailureScreenshot(tester, test.name);
                }

                if (attempts > this.config.maxRetries || !this.config.retryFailedTests) {
                    break;
                }

            } finally {
                if (tester) {
                    await tester.cleanup();
                }
            }
        }

        result.endTime = new Date();
        result.attempts = attempts;
        result.duration = result.endTime.getTime() - result.startTime.getTime();

        return result;
    }

    /**
     * Capture screenshot on test failure
     */
    private async captureFailureScreenshot(tester: WebUITester, testName: string): Promise<string> {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
        const filename = `${testName.replace(/\s+/g, '_')}_${timestamp}_FAILED.png`;
        const path = `${this.config.reportPath}/screenshots/${filename}`;

        mkdirSync(dirname(path), { recursive: true });
        await tester.takeScreenshot(path);

        console.log(chalk.gray(`    📸 Screenshot saved: ${filename}`));
        return path;
    }

    /**
     * Calculate overall test statistics
     */
    private calculateStatistics(report: MasterTestReport): void {
        report.totalTests = report.suiteResults.reduce((sum, s) => sum + s.testResults.length, 0);
        report.passedTests = report.suiteResults.reduce((sum, s) => sum + s.passedCount, 0);
        report.failedTests = report.suiteResults.reduce((sum, s) => sum + s.failedCount, 0);
        report.passRate = report.totalTests > 0 ? (report.passedTests / report.totalTests) * 100 : 0;
        report.duration = report.endTime.getTime() - report.startTime.getTime();
    }

    /**
     * Execute items with concurrency limit
     */
    private async executeWithConcurrencyLimit<T, R>(
        items: T[],
        fn: (item: T) => Promise<R>,
        limit: number
    ): Promise<R[]> {
        const results: R[] = [];
        const executing: Promise<void>[] = [];

        for (const item of items) {
            const promise = fn(item).then(result => {
                results.push(result);
            });

            executing.push(promise);

            if (executing.length >= limit) {
                await Promise.race(executing);
                executing.splice(executing.findIndex(p => p === promise), 1);
            }
        }

        await Promise.all(executing);
        return results;
    }
}
