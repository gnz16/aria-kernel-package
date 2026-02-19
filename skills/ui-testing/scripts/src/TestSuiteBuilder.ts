import type { TestSuite, TestCase } from './types.js';
import type { MasterTestingSkill } from './MasterTestingSkill.js';

/**
 * TestSuiteBuilder - Fluent API for building test suites
 * Mirrors the C# TestSuiteBuilder functionality
 */
export class TestSuiteBuilder {
    private suite: TestSuite;

    constructor(
        name: string,
        private master: MasterTestingSkill
    ) {
        this.suite = {
            name,
            description: '',
            priority: 100,
            stopOnFailure: false,
            tests: [],
            tags: {}
        };
    }

    /**
     * Set suite description
     */
    withDescription(description: string): this {
        this.suite.description = description;
        return this;
    }

    /**
     * Set suite priority (lower = runs first)
     */
    withPriority(priority: number): this {
        this.suite.priority = priority;
        return this;
    }

    /**
     * Stop suite execution on first failure
     */
    stopOnFirstFailure(): this {
        this.suite.stopOnFailure = true;
        return this;
    }

    /**
     * Add a regular test
     */
    addTest(name: string, action: (tester: any) => Promise<void>): this {
        this.suite.tests.push({
            name,
            description: '',
            priority: this.suite.tests.length * 10,
            action,
            tags: [],
            requiresAI: false,
            estimatedTokens: 0
        });
        return this;
    }

    /**
     * Add a test that requires AI validation
     */
    addAITest(name: string, action: (tester: any) => Promise<void>, estimatedTokens: number): this {
        this.suite.tests.push({
            name,
            description: '',
            priority: this.suite.tests.length * 10,
            action,
            tags: [],
            requiresAI: true,
            estimatedTokens
        });
        return this;
    }

    /**
     * Add a tag to the suite
     */
    addTag(key: string, value: string): this {
        this.suite.tags[key] = value;
        return this;
    }

    /**
     * Build and register the suite
     */
    build(): TestSuite {
        this.master.registerSuite(this.suite);
        return this.suite;
    }
}
