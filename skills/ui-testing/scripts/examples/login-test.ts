import { WebUITester } from '../src/WebUITester.js';

/**
 * Example: Login Test
 * Demonstrates basic navigation, form filling, and assertions
 */
async function loginTest() {
    const tester = new WebUITester({
        headless: false,
        slowMo: 100
    });

    try {
        // Initialize browser
        await tester.init();

        // Navigate to login page
        await tester.navigateTo('https://practicetestautomation.com/practice-test-login/');

        // Fill in login form (coded logic - no AI tokens used)
        await tester.enterText('#username', 'student');
        await tester.enterText('#password', 'Password123');
        await tester.clickElement('#submit');

        // Wait for navigation
        await tester.waitForSeconds(2);

        // Assertions (coded logic - no AI tokens used)
        await tester.assertUrlContains('logged-in-successfully');
        await tester.assertElementExists('.post-title');
        await tester.assertTextContains('.post-title', 'Logged In Successfully');

        // Check specific elements
        await tester.assertElementVisible('.post-content');

        console.log('\n✅ Login test completed successfully!\n');

        // Save logs
        tester.getLogger().saveToFile('./test-results/login-test.log');

    } catch (error) {
        console.error('\n❌ Test failed:', error);

        // Take screenshot on failure
        await tester.takeScreenshot('./test-results/login-test-failure.png');
        throw error;

    } finally {
        // Cleanup
        await tester.cleanup();
    }
}

// Run the test
loginTest().catch(console.error);
