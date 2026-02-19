---
name: config-builder
description: Create and maintain GEMINI.md configuration files for projects. Generates workspace-specific AI assistant configurations with development preferences, code style, testing philosophy, and project context. Use when setting up new projects, documenting team standards, or creating AI-optimized workspace configurations.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# Config Builder

Create professional GEMINI.md configuration files that optimize AI assistant behavior for your projects.

## When to Use

**ALWAYS use for:**
- New project setup
- Team onboarding documentation
- Standardizing development practices
- Documenting project-specific context

**Use when requested:**
- "Create GEMINI.md for my project"
- "Generate workspace configuration"
- "Add AWS preferences to config"
- "Document our coding standards"

## What is GEMINI.md?

A workspace-specific configuration file that teaches AI assistants about:
- **Languages & Frameworks** - Preferred stack
- **Code Style** - Naming, formatting, documentation
- **Testing Philosophy** - TDD, coverage requirements
- **Project Context** - Domain, architecture, goals
- **Workflow Patterns** - Common tasks and commands

## Available Templates

### 1. base-config
**Use for:** Any new project  
**Includes:** Minimal starting point with essential sections

### 2. web-dev-config
**Use for:** React/Next.js/Frontend projects  
**Includes:**
- TypeScript preferences
- Component structure
- State management patterns
- Build/deploy workflows

### 3. backend-config
**Use for:** Node.js/Python API projects  
**Includes:**
- API design patterns
- Database preferences
- Authentication/authorization
- Deployment strategies

### 4. aws-config
**Use for:** AWS cloud projects  
**Includes:**
- AWS service preferences
- IAM best practices
- Infrastructure as Code
- Serverless patterns

### 5. fullstack-config
**Use for:** Complete applications  
**Includes:**
- Frontend + Backend preferences
- Deployment pipelines
- Testing strategies
- Architecture patterns

## Core Sections

### 1. Workspace Context
```markdown
# Workspace Context

This workspace contains [project description].

## Development Preferences

### Languages & Frameworks
- **Primary Language**: TypeScript
- **Web Framework**: Next.js
- **Build Tools**: Vite, npm
```

### 2. Code Style
```markdown
### Code Style
- **TypeScript**: Strict mode enabled
- **Formatting**: Prettier
- **Naming**: camelCase for variables, PascalCase for classes
- **Documentation**: JSDoc comments for public APIs
```

### 3. Testing Philosophy
```markdown
### Testing Philosophy
- **Approach**: Test-Driven Development (TDD)
- **Coverage**: Minimum 80%
- **Automation**: All tests run in CI/CD
```

### 4. Project Context
```markdown
## Project Context

### Main Projects
- **[Project Name]** - Description

### Common Tasks
- Creating and testing features
- Deploying to production
- Database migrations
```

## Usage Patterns

### Pattern 1: Generate from Template
```markdown
User: "Create a GEMINI.md for my Next.js project"

1. Detect project type (package.json, tsconfig.json)
2. Select web-dev-config template
3. Customize with project specifics
4. Generate GEMINI.md in workspace root
```

### Pattern 2: Add Section
```markdown
User: "Add AWS preferences to my config"

1. Read existing GEMINI.md
2. Insert AWS section from aws-config template
3. Merge with existing content
4. Update file
```

### Pattern 3: Validate Existing
```markdown
User: "Review my GEMINI.md"

1. Check for required sections
2. Validate section structure
3. Suggest improvements
4. Flag missing best practices
```

## Configuration Structure

```markdown
# Workspace Context

Brief overview of the workspace and its purpose.

## Development Preferences

### Languages & Frameworks
List of primary technologies and tools.

### Code Style
Formatting, naming conventions, documentation standards.

### Testing Philosophy
Testing approach, coverage requirements, automation.

### Documentation Standards
How to document code, APIs, and architecture.

## Project Context

### Main Projects
List of projects in workspace with descriptions.

### Common Tasks
Frequent development tasks and workflows.

### Tools & Technologies
Development tools, package managers, etc.

## Workflow Patterns

### [Workflow Name]
Description of common workflows.

## Preferences

- **Verbose Logging**: true/false
- **Error Handling**: Strategy
- **Dependencies**: Minimization approach
```

## Best Practices

### 1. Be Specific
```markdown
❌ BAD: "Use TypeScript"
✅ GOOD: "Primary Language: TypeScript with strict mode, ES2022 target"
```

### 2. Include Examples
```markdown
✅ GOOD:
"Testing Framework: Jest
Example: npm test src/**/*.test.ts"
```

### 3. Document Preferences
```markdown
✅ GOOD:
"Prefer async/await over callbacks
Minimize external dependencies
Use descriptive variable names"
```

### 4. Keep Updated
```markdown
✅ GOOD: Review and update GEMINI.md when:
- Adding new frameworks
- Changing coding standards
- Updating workflows
```

## Template Selection Guide

| Project Type | Template | Key Features |
|--------------|----------|--------------|
| React/Next.js | web-dev-config | Component patterns, TypeScript |
| Node.js API | backend-config | REST APIs, databases |
| AWS Serverless | aws-config | Lambda, DynamoDB, IAM |
| Full-stack app | fullstack-config | Complete stack |
| Any project | base-config | Minimal essentials |

## Commands

### Generate New Config
```bash
# Creates GEMINI.md in current directory
cd ~/.gemini/skills/config-builder/scripts
node generate-config.js --template web-dev --output ~/my-project/GEMINI.md
```

### Validate Existing
```bash
node validate-config.js ~/my-project/GEMINI.md
```

### Add Section
```bash
node add-section.js --section aws --output ~/my-project/GEMINI.md
```

## Integration with Other Skills

Works with:
- **coding-standards** - Populate code style section
- **test-driven-development** - Document TDD philosophy
- **react-best-practices** - Add React preferences
- **backend-patterns** - Include API patterns

## Example Workflow

```typescript
// User: "Create GEMINI.md for my Next.js e-commerce project"

// 1. Detect project
const projectType = detectProjectType('./package.json');
// → "next.js"

// 2. Select template
const template = selectTemplate(projectType);
// → "web-dev-config"

// 3. Customize
const config = customizeTemplate(template, {
  projectName: 'E-commerce Platform',
  primaryLanguage: 'TypeScript',
  testing: 'Jest + React Testing Library',
  deployment: 'Vercel'
});

// 4. Generate
writeFile('./GEMINI.md', config);
```

## Notes

- **Location**: Place GEMINI.md in workspace root
- **Format**: Markdown for readability
- **Versioning**: Track in Git
- **Sharing**: Share across team for consistency
- **Updates**: Review monthly or when standards change

## Quick Start

1. **Identify project type** - React, API, AWS, etc.
2. **Choose template** - Select matching template
3. **Generate config** - Run generation script
4. **Customize** - Add project-specific details
5. **Commit** - Add to version control

---

**Create professional workspace configurations in minutes!**
