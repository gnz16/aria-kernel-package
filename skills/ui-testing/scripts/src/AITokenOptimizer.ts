import chalk from 'chalk';

/**
 * AITokenOptimizer - Tracks and optimizes AI token usage
 * Mirrors the C# AITokenOptimizer functionality
 */
export class AITokenOptimizer {
    private totalTokensUsed = 0;
    private tokensByTest: Map<string, number> = new Map();
    private currentTest: string | null = null;
    private currentTestTokens = 0;

    /**
     * Begin tracking tokens for a test
     */
    beginTest(testName: string): void {
        this.currentTest = testName;
        this.currentTestTokens = 0;
    }

    /**
     * End tracking tokens for current test
     */
    endTest(): void {
        if (this.currentTest) {
            this.tokensByTest.set(this.currentTest, this.currentTestTokens);
            this.totalTokensUsed += this.currentTestTokens;
            this.currentTest = null;
            this.currentTestTokens = 0;
        }
    }

    /**
     * Record token usage for current test
     */
    recordTokenUsage(tokens: number): void {
        this.currentTestTokens += tokens;
    }

    /**
     * Get total tokens used across all tests
     */
    getTotalTokens(): number {
        return this.totalTokensUsed;
    }

    /**
     * Print detailed token usage report
     */
    printUsageReport(): void {
        console.log('\n' + chalk.cyan('╔════════════════════════════════════════════════╗'));
        console.log(chalk.cyan('║           AI TOKEN USAGE REPORT                ║'));
        console.log(chalk.cyan('╚════════════════════════════════════════════════╝'));
        console.log(`\nTotal Tokens Used: ${chalk.yellow(this.totalTokensUsed.toLocaleString())}`);

        if (this.tokensByTest.size > 0) {
            console.log(chalk.gray('\nBreakdown by Test:'));

            const sorted = Array.from(this.tokensByTest.entries())
                .sort((a, b) => b[1] - a[1]);

            for (const [testName, tokens] of sorted) {
                console.log(`  • ${testName}: ${chalk.yellow(tokens.toLocaleString())} tokens`);
            }
        } else {
            console.log(chalk.green('\n✓ All tests executed using coded logic only (Zero tokens!)'));
        }
    }

    /**
     * Reset all counters
     */
    reset(): void {
        this.totalTokensUsed = 0;
        this.tokensByTest.clear();
        this.currentTest = null;
        this.currentTestTokens = 0;
    }
}
