import { WebUITester } from '../src/WebUITester.js';

/**
 * Example: Form Submission Workflow
 * Demonstrates the workflow builder pattern for complex test sequences
 */
async function formWorkflowTest() {
    const tester = new WebUITester({
        headless: false,
        slowMo: 100
    });

    try {
        await tester.init();

        // Create a workflow for form submission
        const workflow = tester.createWorkflow('Contact Form Submission Test')
            .addStep(async () => {
                await tester.navigateTo('https://www.selenium.dev/selenium/web/web-form.html');
            })
            .addStep(async () => {
                await tester.enterText('#my-text-id', 'John Doe');
            })
            .addStep(async () => {
                await tester.enterText('[name="my-password"]', 'SecurePassword123');
            })
            .addStep(async () => {
                await tester.enterText('[name="my-textarea"]', 'This is a test message for the contact form.');
            })
            .addStep(async () => {
                await tester.selectDropdown('[name="my-select"]', 'Two');
            })
            .addStep(async () => {
                await tester.check('#my-check-1');
            })
            .addStep(async () => {
                await tester.check('#my-radio-2');
            })
            .addStep(async () => {
                await tester.clickElement('button[type="submit"]');
            })
            .addStep(async () => {
                await tester.waitForSeconds(1);
                await tester.assertUrlContains('submitted');
            })
            .addStep(async () => {
                await tester.assertElementExists('h1');
                await tester.assertTextEquals('h1', 'Form submitted');
            });

        // Execute the entire workflow
        await workflow.execute();

        console.log('\n✅ Form workflow test completed successfully!\n');
        console.log(`Total steps: ${workflow.getStepCount()}`);

        // Save logs
        tester.getLogger().saveToFile('./test-results/form-workflow-test.log');

    } catch (error) {
        console.error('\n❌ Test failed:', error);
        await tester.takeScreenshot('./test-results/form-workflow-failure.png');
        throw error;

    } finally {
        await tester.cleanup();
    }
}

// Run the test
formWorkflowTest().catch(console.error);
