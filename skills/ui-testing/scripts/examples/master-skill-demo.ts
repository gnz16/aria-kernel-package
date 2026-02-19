import { MasterTestingSkill } from '../src/MasterTestingSkill.js';
import type { WebUITester } from '../src/WebUITester.js';

/**
 * COMPREHENSIVE EXAMPLE - Using Master Testing Skill
 * Demonstrates the full power of the orchestration layer
 */

// Initialize Master Skill
const master = new MasterTestingSkill();

// ==================== REGISTER TEST SUITES ====================

// Suite 1: Login &  Authentication
master.createSuite('Login & Authentication')
    .withDescription('Tests for user authentication flows')
    .withPriority(10)
    .addTest('Valid Login', async (tester: WebUITester) => {
        await tester.navigateTo('https://practicetestautomation.com/practice-test-login/');
        await tester.enterText('#username', 'student');
        await tester.enterText('#password', 'Password123');
        await tester.clickElement('#submit');
        await tester.assertUrlContains('logged-in-successfully');
        await tester.assertElementExists('.post-title');
    })
    .addTest('Invalid Credentials', async (tester: WebUITester) => {
        await tester.navigateTo('https://practicetestautomation.com/practice-test-login/');
        await tester.enterText('#username', 'wronguser');
        await tester.enterText('#password', 'wrongpass');
        await tester.clickElement('#submit');
        await tester.assertElementVisible('#error');
    })
    .addTag('category', 'authentication')
    .addTag('priority', 'high')
    .build();

// Suite 2: Form Interactions
master.createSuite('Form Interactions')
    .withDescription('Test form submissions and validations')
    .withPriority(20)
    .addTest('Complete Form Submission', async (tester: WebUITester) => {
        await tester.navigateTo('https://www.selenium.dev/selenium/web/web-form.html');
        await tester.enterText('#my-text-id', 'Test User');
        await tester.enterText('[name="my-password"]', 'SecurePass123');
        await tester.enterText('[name="my-textarea"]', 'This is a test message');
        await tester.selectDropdown('[name="my-select"]', 'Two');
        await tester.check('#my-check-1');
        await tester.check('#my-radio-2');
        await tester.clickElement('button[type="submit"]');
        await tester.waitForSeconds(1);
        await tester.assertUrlContains('submitted');
    })
    .addTag('category', 'forms')
    .build();

// Suite 3: Navigation & UI Elements
master.createSuite('Navigation & UI Elements')
    .withDescription('Test various UI interactions')
    .withPriority(30)
    .addTest('Dropdown Interaction', async (tester: WebUITester) => {
        await tester.navigateTo('https://the-internet.herokuapp.com/dropdown');
        await tester.selectDropdown('#dropdown', 'Option 1');
        await tester.waitForSeconds(1);
        await tester.selectDropdownByValue('#dropdown', '2');
    })
    .addTest('Checkbox Interactions', async (tester: WebUITester) => {
        await tester.navigateTo('https://the-internet.herokuapp.com/checkboxes');
        await tester.check('input[type="checkbox"]:first-child');
        await tester.assertElementChecked('input[type="checkbox"]:first-child');
        await tester.assertElementCount('input[type="checkbox"]', 2);
    })
    .addTest('Hover Actions', async (tester: WebUITester) => {
        await tester.navigateTo('https://the-internet.herokuapp.com/hovers');
        await tester.hoverElement('.figure:first-child');
        await tester.waitForSeconds(1);
    })
    .build();

// Suite 4: Advanced Scenarios (Optional AI Validation)
master.createSuite('Advanced Scenarios')
    .withDescription('Complex tests with AI validation')
    .withPriority(40)
    .addTest('JavaScript Execution', async (tester: WebUITester) => {
        await tester.navigateTo('https://the-internet.herokuapp.com/');
        const title = await tester.executeScript<string>('return document.title');
        console.log(`      Page title: "${title}"`);
        await tester.assertElementVisible('h1');
    })
    .addAITest('Validate Page Layout', async (tester: WebUITester) => {
        await tester.navigateTo('https://the-internet.herokuapp.com/');
        // This would use AI validation in production
        // await tester.validateWithPrompt('Does the page look correctly loaded?');
    }, 150)
    .build();

// ==================== EXECUTION ====================

async function main() {
    const args = process.argv.slice(2);

    try {
        if (args[0] === '--parallel') {
            console.log('\n🚀 Running tests in PARALLEL mode\n');
            await master.executeParallel(4);

        } else if (args[0] === '--suite' && args[1]) {
            console.log(`\n🎯 Running specific suite: ${args[1]}\n`);
            await master.executeSuiteByName(args[1]);

        } else if (args[0] === '--test' && args[1]) {
            console.log(`\n🎯 Running specific test: ${args[1]}\n`);
            await master.executeTest(args[1]);

        } else if (args[0] === '--save-config') {
            master.saveConfiguration('test-config.json');
            console.log('\n✅ Configuration saved\n');

        } else {
            console.log('\n🎯 Running ALL test suites sequentially\n');
            await master.executeAllTests();
        }

    } catch (error) {
        console.error('\n❌ Execution failed:', error);
        process.exit(1);
    }
}

// Run the master script
main();
