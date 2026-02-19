import type { TestLogger } from './TestLogger.js';

/**
 * TestWorkflow - Builder pattern for complex test sequences
 * Mirrors the C# TestWorkflow functionality
 */
export class TestWorkflow {
    private steps: Array<() => Promise<void>> = [];

    constructor(
        private name: string,
        private logger: TestLogger
    ) { }

    /**
     * Add a step to the workflow
     */
    addStep(step: () => Promise<void>): TestWorkflow {
        this.steps.push(step);
        return this;
    }

    /**
     * Execute all steps in sequence
     */
    async execute(): Promise<void> {
        this.logger.log(`Executing workflow: ${this.name}`);

        const startTime = Date.now();
        let stepNumber = 1;

        for (const step of this.steps) {
            try {
                this.logger.log(`Step ${stepNumber}/${this.steps.length}`);
                await step();
                stepNumber++;
            } catch (error) {
                this.logger.logError(`Workflow failed at step ${stepNumber}: ${error}`);
                throw error;
            }
        }

        const duration = Date.now() - startTime;
        this.logger.logSuccess(`Workflow completed: ${this.name} (${duration}ms)`);
    }

    /**
     * Get the number of steps in this workflow
     */
    getStepCount(): number {
        return this.steps.length;
    }

    /**
     * Get the workflow name
     */
    getName(): string {
        return this.name;
    }
}
