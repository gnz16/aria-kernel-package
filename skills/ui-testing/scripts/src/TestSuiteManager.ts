import type { TestSuite, TestCase } from './types.js';

/**
 * TestSuiteManager - Manages multiple test suites
 * Mirrors the C# TestSuiteManager functionality
 */
export class TestSuiteManager {
    private suites: Map<string, TestSuite> = new Map();

    /**
     * Add a test suite
     */
    addSuite(suite: TestSuite): void {
        this.suites.set(suite.name, suite);
    }

    /**
     * Get a specific suite by name
     */
    getSuite(name: string): TestSuite | undefined {
        return this.suites.get(name);
    }

    /**
     * Get all suites sorted by priority
     */
    getAllSuites(): TestSuite[] {
        return Array.from(this.suites.values()).sort((a, b) => a.priority - b.priority);
    }

    /**
     * Find a test by name across all suites
     */
    findTest(testName: string): TestCase | undefined {
        for (const suite of this.suites.values()) {
            const test = suite.tests.find(t => t.name === testName);
            if (test) return test;
        }
        return undefined;
    }

    /**
     * Get total number of tests across all suites
     */
    getTotalTestCount(): number {
        return Array.from(this.suites.values()).reduce((sum, suite) => sum + suite.tests.length, 0);
    }
}
