import { WebUITester } from '../src/WebUITester.js';

/**
 * Example: Advanced Features
 * Demonstrates screenshots, waiting, custom validation, and more
 */
async function advancedTest() {
    const tester = new WebUITester({
        headless: false,
        browser: 'chromium',
        recordVideo: false
    });

    try {
        await tester.init();

        console.log('\n🧪 Running Advanced Features Test\n');

        // Test 1: Multiple browser actions
        await tester.navigateTo('https://the-internet.herokuapp.com/');

        // Take a screenshot
        await tester.takeScreenshot('./test-results/homepage.png');

        // Test 2: Dropdown interaction
        await tester.clickElement('text=Dropdown');
        await tester.waitForElement('#dropdown');
        await tester.selectDropdown('#dropdown', 'Option 1');
        await tester.waitForSeconds(1);
        await tester.selectDropdownByValue('#dropdown', '2');

        // Test 3: Navigation
        await tester.goBack();
        await tester.waitForSeconds(1);

        // Test 4: Checkboxes
        await tester.clickElement('text=Checkboxes');
        await tester.assertElementExists('input[type="checkbox"]');
        await tester.check('input[type="checkbox"]:first-child');
        await tester.assertElementChecked('input[type="checkbox"]:first-child');

        // Test 5: Element count
        await tester.assertElementCount('input[type="checkbox"]', 2);

        // Test 6: Hover
        await tester.goBack();
        await tester.clickElement('text=Hovers');
        await tester.waitForElement('.figure');
        await tester.hoverElement('.figure:first-child');
        await tester.waitForSeconds(1);

        // Test 7: JavaScript execution
        const pageTitle = await tester.executeScript<string>('return document.title');
        console.log(`   Page title from JS: "${pageTitle}"`);

        // Test 8: URL assertions
        await tester.assertUrlContains('hovers');

        // Test 9: Visibility checks
        await tester.goBack();
        await tester.assertElementVisible('h1');
        await tester.assertTextContains('h1', 'Welcome');

        // Test 10: Advanced selectors
        await tester.clickElement('Dropdown', 'text');
        await tester.waitForElement('dropdown', 'id');

        console.log('\n✅ Advanced test completed successfully!\n');

        // Display all logs
        const logs = tester.getLogger().getLogs();
        console.log(`Total actions performed: ${logs.length}`);

        // Save logs
        tester.getLogger().saveToFile('./test-results/advanced-test.log');

        // Optional: AI Validation example (requires API key)
        // Uncomment to test AI validation
        /*
        const aiValidation = await tester.validateWithPrompt(
          'Does the page look correctly loaded with all elements visible?'
        );
        console.log(`AI Validation result: ${aiValidation}`);
        */

    } catch (error) {
        console.error('\n❌ Test failed:', error);
        await tester.takeScreenshot('./test-results/advanced-test-failure.png');
        throw error;

    } finally {
        await tester.cleanup();
    }
}

// Run the test
advancedTest().catch(console.error);
