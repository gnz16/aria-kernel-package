# Selector Strategies for UI Testing

## Selector Priority (Best to Worst)

### 1. data-testid (BEST)
**Why:** Stable, semantic, specifically for testing
```typescript
// HTML
<button data-testid="submit-button">Submit</button>

// Test
await tester.clickElement('[data-testid="submit-button"]');
```

**Pros:**
- Won't change with styling
- Clear testing intent
- Easy to find in code
- Stable across refactors

**Cons:**
- Requires adding attributes to HTML
- Not automatically generated

### 2. ARIA Attributes
**Why:** Accessibility + testing dual purpose
```typescript
// HTML
<button aria-label="Close modal">×</button>

// Test
await tester.clickElement('[aria-label="Close modal"]');
```

**Pros:**
- Improves accessibility
- Semantic meaning
- Recommended by W3C

**Cons:**
- May change with copy updates
- Not always present

### 3. Text Content
**Why:** User-facing, what users see
```typescript
await tester.clickElement('Submit', 'text');
```

**Pros:**
- Tests actual user experience
- No extra attributes needed

**Cons:**
- Changes with copy updates
- Internationalization issues
- Not unique if text repeats

### 4. ID Attributes
**Why:** Unique identifiers
```typescript
// HTML
<input id="email-input" />

// Test
await tester.clickElement('#email-input');
```

**Pros:**
- Usually unique
- Fast selectors

**Cons:**
- May not be present
- Can change during refactors
- Not semantic for testing

### 5. Role + Accessible Name
**Why:** Combines semantics with accessibility
```typescript
await tester.clickElement('button[role="button"][name="Submit"]');
```

**Pros:**
- Good accessibility
- Semantic

**Cons:**
- Verbose
- Not always unique

### 6. CSS Classes (AVOID)
**Why:** Implementation detail, very brittle
```typescript
// BAD
await tester.clickElement('.btn-primary');
```

**Cons:**
- Changes with styling
- Generated classes (.css-xyz-123)
- Not semantic
- Framework-dependent

**Only use when no other option exists**

### 7. Deep Nesting (NEVER)
```typescript
// NEVER DO THIS
await tester.clickElement('div > div > div:nth-child(3) > button');
```

**Why it's terrible:**
- Breaks with ANY DOM change
- Not readable
- Not maintainable
- Flaky

## Recommended Patterns

### Pattern 1: Add data-testid to Components
```tsx
// React Component
export function SubmitButton({ onClick }) {
  return (
    <button 
      data-testid="submit-button"
      onClick={onClick}
      className="btn-primary"
    >
      Submit
    </button>
  );
}

// Test
await tester.clickElement('[data-testid="submit-button"]');
```

### Pattern 2: Use ARIA for Interactive Elements
```tsx
// React Component
export function CloseButton({ onClose }) {
  return (
    <button 
      aria-label="Close dialog"
      onClick={onClose}
    >
      ×
    </button>
  );
}

// Test
await tester.clickElement('[aria-label="Close dialog"]');
```

### Pattern 3: Combine Selectors for Specificity
```typescript
// When multiple elements have same data-testid
await tester.clickElement('form[data-testid="login-form"] button[data-testid="submit"]');
```

### Pattern 4: Use Playwright's getByRole
```typescript
// Playwright best practice
await page.getByRole('button', { name: 'Submit' }).click();

// In WebUITester
await tester.clickElement('button', 'role');
```

## Selector Debugging

### Check Selector Uniqueness
```typescript
// In browser console
document.querySelectorAll('[data-testid="submit-button"]').length
// Should return 1
```

### Find Element Selectors
```typescript
// In browser DevTools
$('[data-testid="submit-button"]') // jQuery syntax
document.querySelector('[data-testid="submit-button"]') // Vanilla JS
```

### Playwright Inspector
```bash
npx playwright test --debug
```

## Migration from Bad to Good Selectors

### Before (Bad)
```typescript
await tester.clickElement('.css-xyz-123.button.primary');
```

### After (Good)
```typescript
// 1. Add data-testid to HTML
<button data-testid="submit-button" class="css-xyz-123 button primary">

// 2. Update test
await tester.clickElement('[data-testid="submit-button"]');
```

## Framework-Specific Patterns

### React
```tsx
<button data-testid="submit-button">Submit</button>
```

### Vue
```html
<button data-testid="submit-button">Submit</button>
```

### Angular
```html
<button data-testid="submit-button">Submit</button>
```

**Note:** data-testid works across all frameworks!

## Common Mistakes

### ❌ Mistake 1: Using Generated Class Names
```typescript
// BAD
await tester.clickElement('.MuiButton-root-xyz123');
```

### ❌ Mistake 2: nth-child Selectors
```typescript
// BAD
await tester.clickElement('button:nth-child(3)');
```

### ❌ Mistake 3: Deep Nesting
```typescript
// BAD
await tester.clickElement('#main > div.container > form > button');
```

### ✅ Fix: Use data-testid
```typescript
// GOOD
await tester.clickElement('[data-testid="submit-button"]');
```

## Quick Reference

| Selector Type | Priority | Stability | Example |
|--------------|----------|-----------|---------|
| data-testid | 1 (BEST) | ✅✅✅ | `[data-testid="submit"]` |
| ARIA | 2 | ✅✅ | `[aria-label="Close"]` |
| Text | 3 | ✅ | `'Submit'` |
| ID | 4 | ✅ | `#submit` |
| Role | 5 | ✅ | `button[role="button"]` |
| CSS Class | 6 (AVOID) | ❌ | `.btn-primary` |
| Nesting | 7 (NEVER) | ❌❌❌ | `div > div > button` |

**Rule of thumb:** If selector has more than 2 parts, it's probably too specific.
