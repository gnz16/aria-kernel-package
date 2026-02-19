import { WebUITester } from './src/WebUITester.js';
import { MasterTestingSkill } from './src/MasterTestingSkill.js';

const master = new MasterTestingSkill();

master.createSuite('Authentication Flow')
    .withDescription('Tests the custom QR-based login system')
    .withPriority(10) // CRITICAL
    .addTest('Generate QR Code with Phone', async (tester) => {
        await tester.navigateTo('http://localhost:3000/login');

        // Check if on login page
        await tester.assertTextEquals('h1', 'Welcome Back');

        // Enter phone number with delay
        const phoneInput = 'input[type="tel"]';
        await tester.waitForElement(phoneInput);
        await tester.enterText(phoneInput, '+919999999999');

        // Click generate button using text selector
        await tester.clickElement('button:has-text("Generate QR Code")');

        // Should see QR code image
        await tester.waitForElement('img[alt="QR Code"]');
        await tester.assertElementVisible('img[alt="QR Code"]');

        // Should see Simulate Scan button
        await tester.assertElementVisible('button:has-text("Simulate Scan")');

        console.log('✅ QR Code generated successfully');
    })
    .addTest('Simulate Scan and Redirect to Dashboard', async (tester) => {
        await tester.navigateTo('http://localhost:3000/login');

        // Enter phone and generate QR
        await tester.enterText('input[type="tel"]', '+911111111111');
        await tester.clickElement('button:has-text("Generate QR Code")');
        await tester.waitForElement('button:has-text("Simulate Scan")');

        // Click simulate scan
        await tester.clickElement('button:has-text("Simulate Scan")');

        // Should redirect to dashboard
        await tester.waitForSeconds(2);
        await tester.assertUrlContains('/dashboard');

        console.log('✅ Login simulation and redirection successful');
    })
    .build();

await master.executeAllTests();
