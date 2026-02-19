# Common UI Testing Patterns

## Authentication Patterns

### Login Flow
```typescript
test('successful login redirects to dashboard', async () => {
  const tester = new WebUITester();
  await tester.init();
  
  await tester.navigateTo('https://app.com/login');
  await tester.enterText('[data-testid="email"]', 'user@test.com');
  await tester.enterText('[data-testid="password"]', 'Password123!');
  await tester.clickElement('[data-testid="login-button"]');
  
  await tester.assertUrlContains('/dashboard');
  await tester.assertElementVisible('[data-testid="user-menu"]');
  
  await tester.cleanup();
});
```

### Logout Flow
```typescript
test('logout clears session and redirects to login', async () => {
  // Setup: login first
  await loginAsTestUser(tester);
  
  await tester.clickElement('[data-testid="user-menu"]');
  await tester.clickElement('[data-testid="logout-button"]');
  
  await tester.assertUrlEquals('/login');
  await tester.assertElementNotExists('[data-testid="user-menu"]');
});
```

### Invalid Credentials
```typescript
test('shows error for invalid credentials', async () => {
  await tester.navigateTo('https://app.com/login');
  await tester.enterText('[data-testid="email"]', 'wrong@test.com');
  await tester.enterText('[data-testid="password"]', 'wrongpass');
  await tester.clickElement('[data-testid="login-button"]');
  
  await tester.assertElementVisible('[data-testid="error-message"]');
  await tester.assertTextContains('[data-testid="error-message"]', 'Invalid');
  await tester.assertUrlEquals('/login'); // Should stay on login page
});
```

## Form Validation Patterns

### Required Field Validation
```typescript
test('shows error for empty required field', async () => {
  await tester.navigateTo('https://app.com/contact');
  await tester.clickElement('[data-testid="submit"]');
  
  await tester.assertElementVisible('[data-testid="name-error"]');
  await tester.assertTextContains('[data-testid="name-error"]', 'required');
});
```

### Email Format Validation
```typescript
test('validates email format', async () => {
  await tester.enterText('[data-testid="email"]', 'invalid-email');
  await tester.clickElement('[data-testid="submit"]');
  
  await tester.assertElementVisible('[data-testid="email-error"]');
  await tester.assertTextContains('[data-testid="email-error"]', 'valid email');
});
```

### Successful Form Submission
```typescript
test('submits form with valid data', async () => {
  await tester.enterText('[data-testid="name"]', 'John Doe');
  await tester.enterText('[data-testid="email"]', 'john@example.com');
  await tester.enterText('[data-testid="message"]', 'Test message');
  await tester.clickElement('[data-testid="submit"]');
  
  await tester.assertElementVisible('[data-testid="success-message"]');
  await tester.assertTextContains('[data-testid="success-message"]', 'Thank you');
});
```

## Navigation Patterns

### Menu Navigation
```typescript
test('navigates to pricing page from menu', async () => {
  await tester.navigateTo('https://app.com');
  await tester.clickElement('[data-testid="nav-pricing"]');
  
  await tester.assertUrlContains('/pricing');
  await tester.assertTextContains('h1', 'Pricing Plans');
});
```

### Breadcrumb Navigation
```typescript
test('breadcrumbs navigate to parent pages', async () => {
  await tester.navigateTo('https://app.com/products/category/item');
  await tester.clickElement('[data-testid="breadcrumb-category"]');
  
  await tester.assertUrlContains('/products/category');
});
```

## Modal Patterns

### Open/Close Modal
```typescript
test('modal opens and closes correctly', async () => {
  await tester.clickElement('[data-testid="open-modal"]');
  await tester.assertElementVisible('[data-testid="modal"]');
  
  await tester.clickElement('[data-testid="close-modal"]');
  await tester.assertElementNotVisible('[data-testid="modal"]');
});
```

### Modal Form Submission
```typescript
test('submits form in modal', async () => {
  await tester.clickElement('[data-testid="open-modal"]');
  await tester.enterText('[data-testid="modal-input"]', 'Test data');
  await tester.clickElement('[data-testid="modal-submit"]');
  
  await tester.assertElementNotVisible('[data-testid="modal"]');
  await tester.assertElementVisible('[data-testid="success-toast"]');
});
```

## E-Commerce Patterns

### Add to Cart
```typescript
test('adds product to cart', async () => {
  await tester.navigateTo('https://shop.com/product/123');
  await tester.clickElement('[data-testid="add-to-cart"]');
  
  await tester.assertTextContains('[data-testid="cart-count"]', '1');
  await tester.assertElementVisible('[data-testid="cart-notification"]');
});
```

### Checkout Flow
```typescript
test('completes checkout process', async () => {
  // Setup: Add item to cart
  await addItemToCart(tester);
  
  await tester.clickElement('[data-testid="checkout"]');
  await tester.enterText('[data-testid="shipping-name"]', 'John Doe');
  await tester.enterText('[data-testid="shipping-address"]', '123 Main St');
  await tester.clickElement('[data-testid="continue-to-payment"]');
  
  // Payment step
  await tester.enterText('[data-testid="card-number"]', '4111111111111111');
  await tester.enterText('[data-testid="card-exp"]', '12/25');
  await tester.clickElement('[data-testid="place-order"]');
  
  await tester.assertUrlContains('/order-confirmation');
  await tester.assertElementVisible('[data-testid="order-number"]');
});
```

## Search Patterns

### Search with Results
```typescript
test('displays search results', async () => {
  await tester.enterText('[data-testid="search-input"]', 'laptop');
  await tester.clickElement('[data-testid="search-button"]');
  
  await tester.assertUrlContains('?q=laptop');
  await tester.assertElementExists('[data-testid="search-result"]');
});
```

### Search with No Results
```typescript
test('shows no results message', async () => {
  await tester.enterText('[data-testid="search-input"]', 'xyznonexistent');
  await tester.clickElement('[data-testid="search-button"]');
  
  await tester.assertElementVisible('[data-testid="no-results"]');
  await tester.assertTextContains('[data-testid="no-results"]', 'No results found');
});
```

## Helper Functions

### Login Helper
```typescript
async function loginAsTestUser(tester: WebUITester) {
  await tester.navigateTo('https://app.com/login');
  await tester.enterText('[data-testid="email"]', 'test@example.com');
  await tester.enterText('[data-testid="password"]', 'TestPass123!');
  await tester.clickElement('[data-testid="login-button"]');
  await tester.assertUrlContains('/dashboard');
}
```

### Add to Cart Helper
```typescript
async function addItemToCart(tester: WebUITester, productId: string = '123') {
  await tester.navigateTo(`https://shop.com/product/${productId}`);
  await tester.clickElement('[data-testid="add-to-cart"]');
  await tester.assertTextContains('[data-testid="cart-count"]', '1');
}
```

### Wait for Network Idle
```typescript
async function waitForNetworkIdle(tester: WebUITester) {
  await tester.page.waitForLoadState('networkidle');
}
```
