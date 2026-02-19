/**
 * Selector types supported by the testing framework
 */
export enum SelectorType {
    CSS = 'css',
    XPath = 'xpath',
    Text = 'text',
    ID = 'id',
    TestId = 'data-testid',
    Role = 'role'
}

/**
 * Configuration options for WebUITester
 */
export interface TesterConfig {
    headless?: boolean;
    timeoutMs?: number;
    slowMo?: number;
    viewport?: {
        width: number;
        height: number;
    };
    browser?: 'chromium' | 'firefox' | 'webkit';
    recordVideo?: boolean;
    screenshotOnFailure?: boolean;
}

/**
 * Request for AI-based validation
 */
export interface AIValidationRequest {
    prompt: string;
    screenshot?: string;
    context?: string;
    timestamp: Date;
}

/**
 * Response from AI validation
 */
export interface AIValidationResponse {
    passed: boolean;
    reason?: string;
    confidence?: number;
}

/**
 * Log entry structure
 */
export interface LogEntry {
    timestamp: Date;
    level: 'info' | 'success' | 'error' | 'warning';
    message: string;
}

/**
 * Configuration for the testing framework
 */
export interface TestConfiguration {
    browserType: 'chromium' | 'firefox' | 'webkit';
    headless: boolean;
    timeout: number;
    retryFailedTests: boolean;
    maxRetries: number;
    screenshotOnFailure: boolean;
    videoRecording: boolean;
    aiValidationEnabled: boolean;
    tokenBudget: number;
    parallelExecution: boolean;
    maxParallelThreads: number;
    reportFormat: 'HTML' | 'JSON' | 'CONSOLE';
    reportPath: string;
}

/**
 * Test suite definition
 */
export interface TestSuite {
    name: string;
    description?: string;
    priority: number;
    stopOnFailure: boolean;
    tests: TestCase[];
    tags: Record<string, string>;
}

/**
 * Individual test case
 */
export interface TestCase {
    name: string;
    description?: string;
    priority: number;
    action: (tester: any) => Promise<void>;
    tags: string[];
    requiresAI: boolean;
    estimatedTokens: number;
}

/**
 * Test execution results
 */
export enum TestStatus {
    Passed = 'PASSED',
    Failed = 'FAILED',
    Skipped = 'SKIPPED',
    Running = 'RUNNING'
}

export interface TestResult {
    testName: string;
    startTime: Date;
    endTime: Date;
    status: TestStatus;
    message: string;
    stackTrace?: string;
    screenshotPath?: string;
    attempts: number;
    duration: number;
}

export interface TestSuiteResult {
    suiteName: string;
    startTime: Date;
    endTime: Date;
    testResults: TestResult[];
    passedCount: number;
    failedCount: number;
    duration: number;
}

export interface MasterTestReport {
    startTime: Date;
    endTime: Date;
    configuration: TestConfiguration;
    suiteResults: TestSuiteResult[];
    totalTests: number;
    passedTests: number;
    failedTests: number;
    skippedTests: number;
    passRate: number;
    duration: number;
}
