# Antigravity Skills Library

A comprehensive collection of **260+ modular skills** that provide specialized capabilities across development, design, security, cloud platforms, and more. These skills act as expert knowledge modules that enhance AI agent capabilities for complex professional workflows.

**Last Updated**: January 21, 2026  
**Total Skills**: 260 directories | 252 active SKILL.md files  
**Location**: `/Users/apple/.gemini/skills/`

---

## 📂 Directory Structure

```
/Users/apple/.gemini/skills/
├── skill-name/              # Individual skill directory
│   ├── SKILL.md             # Core skill definition & instructions (required)
│   ├── scripts/             # Helper scripts & utilities (optional)
│   ├── examples/            # Usage examples & templates (optional)
│   └── resources/           # Additional files, templates, assets (optional)
├── LICENSE.txt              # License information
├── requirements.txt         # Python dependencies
├── recalc.py               # Excel formula recalculation script
├── reference.md            # PDF processing advanced reference
└── README.md               # This file
```

---

## 🚀 Quick Start

### How Skills Work in Antigravity

Skills are **automatically available** to the AI agent when working in your environment. The agent:

1. **Auto-detects** relevant skills based on your task
2. **Reads** the `SKILL.md` file for specialized instructions
3. **Applies** expert knowledge to solve complex problems
4. **Uses** scripts and resources when needed

### Manual Skill Invocation

While skills activate automatically, you can explicitly reference them:

```text
"Use the xlsx skill to create a financial model"
"Apply the ui-ux-pro-max skill for this design"
"Follow the systematic-debugging skill to fix this issue"
```

### Installation for New Projects

To add skills to a specific project workspace:

```bash
# Copy skills to project (optional - global skills are already available)
cp -r /Users/apple/.gemini/skills /path/to/your/project/.agent/

# Or create symbolic link
ln -s /Users/apple/.gemini/skills /path/to/your/project/.agent/skills
```

---

## 🎯 Skill Categories

### 🎨 Creative & Design (20+ skills)
Visual design, UI/UX, and creative content creation.

- **`algorithmic-art`** - Create algorithmic and generative art using p5.js
- **`canvas-design`** - Design posters and artwork with professional design principles
- **`frontend-design`** - Build production-grade frontend interfaces and components
- **`ui-ux-pro-max`** - Professional UI/UX design with color schemes, typography, layouts
- **`web-artifacts-builder`** - Build complex modern web apps (React, Tailwind, Shadcn/ui)
- **`theme-factory`** - Generate cohesive themes for documents, slides, HTML
- **`brand-guidelines-anthropic`** - Apply Anthropic official brand design standards
- **`brand-guidelines-community`** - Community-contributed brand guidelines
- **`slack-gif-creator`** - Create high-quality GIFs optimized for Slack
- **`mobile-design`** - Mobile-first design patterns
- **`interactive-portfolio`** - Build interactive portfolio websites
- **`3d-web-experience`** - Create 3D web experiences
- **`scroll-experience`** - Advanced scroll-based animations

### 🛠️ Development & Engineering (50+ skills)
Full-stack development, testing, debugging, and code quality.

**Testing & Quality**
- **`test-driven-development`** - TDD workflow: write tests before implementation
- **`systematic-debugging`** - Structured approach to debugging and issue resolution
- **`webapp-testing`** - Playwright-based web application testing
- **`ui-testing`** - UI component testing strategies
- **`test-fixing`** - Fix failing tests systematically

**Code Review & Collaboration**
- **`receiving-code-review`** - Handle code review feedback effectively
- **`requesting-code-review`** - Request thorough code reviews
- **`code-review-checklist`** - Comprehensive review checklists

**Development Workflows**
- **`finishing-a-development-branch`** - Complete development branches (merge, PR, cleanup)
- **`subagent-driven-development`** - Coordinate multiple agents for parallel tasks
- **`using-git-worktrees`** - Isolated Git worktrees for parallel development
- **`git-pushing`** - Git push workflows and best practices

**Language & Framework Expertise**
- **`javascript-mastery`** - Advanced JavaScript patterns
- **`typescript-expert`** - TypeScript best practices
- **`python-patterns`** - Python design patterns
- **`react-best-practices`** - React development standards
- **`react-patterns`** - Advanced React patterns
- **`nextjs-best-practices`** - Next.js optimization and patterns
- **`nodejs-best-practices`** - Node.js server development
- **`nestjs-expert`** - NestJS framework expertise
- **`bun-development`** - Bun runtime development

**Architecture & Patterns**
- **`architecture`** - Software architecture principles
- **`software-architecture`** - System design patterns
- **`frontend-patterns`** - Frontend architectural patterns
- **`backend-patterns`** - Backend architectural patterns
- **`api-patterns`** - API design and patterns
- **`clean-code`** - Clean code principles

### 📄 Documentation & Office (15+ skills)
Document creation, editing, and professional content generation.

**Office Suite**
- **`docx`** - Create, edit, analyze Word documents
- **`docx-official`** - Official DOCX manipulation
- **`xlsx`** - Excel spreadsheets with formulas, charts, analysis
- **`xlsx-official`** - Official XLSX processing
- **`pptx`** - PowerPoint presentation creation and editing
- **`pptx-official`** - Official PPTX manipulation
- **`pdf`** - PDF processing: extract, merge, split, fill forms
- **`pdf-official`** - Official PDF handling

**Content & Communication**
- **`doc-coauthoring`** - Collaborative structured document writing
- **`internal-comms-anthropic`** - Internal communications (Anthropic style)
- **`internal-comms-community`** - Community internal comms templates
- **`documentation-templates`** - Professional documentation templates
- **`copy-editing`** - Professional copy editing
- **`copywriting`** - Marketing and sales copy

### ☁️ Cloud & Infrastructure (30+ skills)
AWS, Azure, GCP, Docker, Kubernetes, and infrastructure as code.

**AWS Services**
- **`aws-lambda`** - AWS Lambda serverless functions
- **`aws-s3`** - S3 storage management
- **`aws-dynamodb`** - DynamoDB database operations
- **`aws-ec2`** - EC2 instance management
- **`aws-eks`** - Kubernetes on AWS
- **`aws-iam`** - IAM security and permissions
- **`aws-api-gateway`** - API Gateway setup
- **`aws-cloudformation`** - Infrastructure as Code
- **`aws-bedrock`** - AWS Bedrock AI services
- **`aws-serverless`** - Serverless application patterns

**Google Cloud**
- **`gcp-cloud-run`** - Google Cloud Run deployments

**Azure**
- **`azure-functions`** - Azure serverless functions

**Containers & Orchestration**
- **`docker-expert`** - Docker best practices
- **`docker-automation`** - Docker automation workflows
- **`developing-with-docker`** - Docker development environments

**Deployment & Infrastructure**
- **`vercel-deployment`** - Vercel deployment optimization
- **`server-management`** - Server administration
- **`deployment-procedures`** - Deployment checklists

### 🔒 Security & Penetration Testing (40+ skills)
Ethical hacking, vulnerability assessment, and security testing.

**Testing Methodologies**
- **`ethical-hacking-methodology`** - Structured pentesting approach
- **`pentest-checklist`** - Comprehensive testing checklists
- **`pentest-commands`** - Common pentesting commands
- **`red-team-tactics`** - Red team operation strategies
- **`red-team-tools`** - Offensive security tools

**Vulnerability Types**
- **`sql-injection-testing`** - SQL injection identification
- **`xss-html-injection`** - XSS vulnerability testing
- **`file-path-traversal`** - Directory traversal attacks
- **`broken-authentication`** - Auth vulnerability testing
- **`idor-testing`** - Insecure direct object references
- **`file-uploads`** - Malicious upload testing
- **`html-injection-testing`** - HTML injection techniques

**Cloud Security**
- **`aws-penetration-testing`** - AWS security assessment
- **`cloud-penetration-testing`** - Multi-cloud security

**Platform Testing**
- **`wordpress-penetration-testing`** - WordPress security audits

**Tools & Exploitation**
- **`burp-suite-testing`** - Burp Suite techniques
- **`metasploit-framework`** - Metasploit exploitation
- **`sqlmap-database-pentesting`** - Automated SQL injection
- **`shodan-reconnaissance`** - Shodan OSINT
- **`wireshark-analysis`** - Network traffic analysis

**Privilege Escalation**
- **`linux-privilege-escalation`** - Linux privesc techniques
- **`windows-privilege-escalation`** - Windows privesc methods
- **`privilege-escalation-methods`** - General escalation tactics

**Network Protocols**
- **`smtp-penetration-testing`** - SMTP security testing
- **`ssh-penetration-testing`** - SSH hardening and attacks
- **`network-101`** - Network fundamentals

**System Hardening**
- **`active-directory-attacks`** - AD exploitation
- **`security-review`** - Security code review

### 📅 Planning & Workflow (15+ skills)
Task planning, project management, and execution optimization.

- **`brainstorming`** - Structured ideation before work
- **`writing-plans`** - Detailed execution plans for complex tasks
- **`plan-writing`** - Alternative planning approach
- **`planning-with-files`** - File-based planning system (Manus-style)
- **`concise-planning`** - Streamlined planning for speed
- **`executing-plans`** - Execute plans with checkpoints
- **`verification-before-completion`** - Verify work before declaring done
- **`using-superpowers`** - Discover and leverage advanced capabilities
- **`kaizen`** - Continuous improvement methodologies
- **`workflow-automation`** - Automate repetitive workflows
- **`github-workflow-automation`** - GitHub Actions automation

### 🤖 AI & Agent Systems (20+ skills)
AI development, agent frameworks, RAG, and prompt engineering.

**Agent Development**
- **`autonomous-agents`** - Build autonomous AI agents
- **`autonomous-agent-patterns`** - Agent design patterns
- **`ai-agents-architect`** - Agent system architecture
- **`agent-evaluation`** - Agent performance testing
- **`agent-manager-skill`** - Multi-agent orchestration
- **`agent-memory-systems`** - Agent memory and context
- **`agent-tool-builder`** - Build custom agent tools
- **`computer-use-agents`** - Computer-using agents
- **`voice-agents`** - Voice interaction agents
- **`parallel-agents`** - Parallel agent execution
- **`dispatching-parallel-agents`** - Coordinate multiple agents

**AI Frameworks**
- **`langgraph`** - LangGraph development
- **`crewai`** - CrewAI multi-agent systems
- **`langfuse`** - LLM observability

**RAG & Retrieval**
- **`rag-engineer`** - RAG system design
- **`rag-implementation`** - RAG implementation patterns

**Prompt Engineering**
- **`prompt-engineer`** - Advanced prompt techniques
- **`prompt-engineering`** - Prompt optimization
- **`prompt-library`** - Reusable prompt templates
- **`prompt-caching`** - Prompt caching strategies

**LLM Applications**
- **`llm-app-patterns`** - LLM application architecture
- **`research-engineer`** - Research workflows with AI

### 🧩 Integrations & APIs (30+ skills)
Third-party services, APIs, and platform integrations.

**Authentication & Payments**
- **`clerk-auth`** - Clerk authentication
- **`stripe-integration`** - Stripe payment processing
- **`plaid-fintech`** - Plaid financial data

**Databases**
- **`neon-postgres`** - Neon serverless Postgres
- **`prisma-expert`** - Prisma ORM
- **`database-design`** - Database schema design

**Communication**
- **`twilio-communications`** - Twilio SMS/voice
- **`email-systems`** - Email delivery systems
- **`slack-bot-builder`** - Slack bot development
- **`telegram-bot-builder`** - Telegram bot creation
- **`telegram-mini-app`** - Telegram mini apps
- **`discord-bot-architect`** - Discord bot architecture

**Marketing & Analytics**
- **`segment-cdp`** - Segment customer data platform
- **`analytics-tracking`** - Analytics implementation
- **`hubspot-integration`** - HubSpot CRM integration
- **`algolia-search`** - Algolia search implementation

**Workflow & Automation**
- **`inngest`** - Inngest workflow engine
- **`trigger-dev`** - Trigger.dev background jobs
- **`bullmq-specialist`** - BullMQ job queues
- **`upstash-qstash`** - Upstash QStash messaging
- **`zapier-make-patterns`** - Zapier/Make automation

**E-commerce**
- **`shopify-development`** - Shopify app development
- **`shopify-apps`** - Shopify app patterns

**CMS & Platforms**
- **`firebase`** - Firebase backend services
- **`moodle-external-api-development`** - Moodle API integration
- **`salesforce-development`** - Salesforce customization

**Search & Data**
- **`graphql`** - GraphQL API design
- **`notebooklm`** - Google NotebookLM queries

### 💼 WordPress Development (15+ skills)
WordPress themes, plugins, blocks, and optimization.

- **`wp-block-development`** - Gutenberg block creation
- **`wp-block-themes`** - Block-based theme development
- **`wp-plugin-development`** - Plugin architecture
- **`wp-interactivity-api`** - WordPress Interactivity API
- **`wp-performance`** - WordPress performance optimization
- **`wp-phpstan`** - PHP static analysis for WP
- **`wp-playground`** - WordPress Playground development
- **`wp-wpcli-and-ops`** - WP-CLI and DevOps
- **`wp-abilities-api`** - WordPress Abilities API
- **`wp-project-triage`** - WordPress project management
- **`wordpress-router`** - Custom routing in WordPress

### 📱 Marketing & Growth (25+ skills)
SEO, conversion optimization, marketing strategies, and content.

**SEO**
- **`seo-fundamentals`** - SEO best practices
- **`seo-audit`** - Technical SEO audits
- **`programmatic-seo`** - Automated SEO content
- **`schema-markup`** - Structured data implementation
- **`geo-fundamentals`** - Local SEO

**Conversion Optimization (CRO)**
- **`form-cro`** - Form optimization
- **`page-cro`** - Landing page optimization
- **`popup-cro`** - Popup/modal optimization
- **`signup-flow-cro`** - Signup flow improvement
- **`onboarding-cro`** - User onboarding optimization
- **`paywall-upgrade-cro`** - Monetization optimization
- **`ab-test-setup`** - A/B testing implementation

**Marketing Strategy**
- **`marketing-ideas`** - Marketing campaign ideation
- **`marketing-psychology`** - Psychological marketing tactics
- **`launch-strategy`** - Product launch planning
- **`referral-program`** - Viral referral mechanics
- **`free-tool-strategy`** - Freemium lead generation
- **`pricing-strategy`** - Pricing model optimization
- **`app-store-optimization`** - Mobile app ASO
- **`paid-ads`** - Paid advertising campaigns
- **`competitor-alternatives`** - Competitive positioning

**Content**
- **`content-creator`** - Content strategy and creation
- **`social-content`** - Social media content
- **`email-sequence`** - Email drip campaigns

### 🧰 System Extension & Skill Management (10+ skills)
Extend capabilities and manage the skill system itself.

- **`mcp-builder`** - Build MCP (Model Context Protocol) servers
- **`skill-creator`** - Create new skills
- **`skill-developer`** - Develop advanced skills
- **`skill-installer`** - Install skills from repositories
- **`skill-manager`** - Manage and update skills
- **`skill-maintenance`** - Maintain skill library
- **`writing-skills`** - Skill file editing and validation
- **`github-skill-scraper`** - Scrape skills from GitHub
- **`personal-tool-builder`** - Build custom personal tools
- **`viral-generator-builder`** - Build viral content generators

### 🎮 Specialized Applications (15+ skills)
Gaming, browser extensions, OCR, and specialized tools.

- **`game-development`** - Game creation workflows
- **`browser-extension-builder`** - Chrome/Firefox extension development
- **`browser-automation`** - Browser automation with Playwright/Selenium
- **`ocr`** - OCR text extraction
- **`file-organizer`** - Intelligent file organization
- **`config-builder`** - Configuration file generation
- **`app-builder`** - General application scaffolding
- **`i18n-localization`** - Internationalization
- **`performance-profiling`** - Application performance analysis
- **`lint-and-validate`** - Code linting and validation

### 💡 Product & Business (10+ skills)
Product strategy, AI product development, and business planning.

- **`ai-product`** - AI product strategy
- **`ai-wrapper-product`** - AI wrapper business models
- **`micro-saas-launcher`** - Micro-SaaS MVPs
- **`product-manager-toolkit`** - PM frameworks and tools
- **`notion-template-business`** - Business Notion templates
- **`senior-architect`** - Senior technical architecture
- **`senior-fullstack`** - Senior full-stack patterns

### 🎓 Learning & Reference (10+ skills)
System administration, scripting, and foundational knowledge.

- **`bash-linux`** - Bash scripting on Linux
- **`linux-shell-scripting`** - Advanced shell scripting
- **`powershell-windows`** - Windows PowerShell
- **`behavioral-modes`** - Agent behavioral patterns
- **`claude-code-guide`** - Claude coding guidelines
- **`coding-standards`** - Language coding standards
- **`context-window-management`** - Manage context limits
- **`conversation-memory`** - Context and memory patterns

---

## 🔧 System Configuration

### Python Dependencies

Some skills require Python libraries:

```bash
# Install Python dependencies
pip install -r /Users/apple/.gemini/skills/requirements.txt

# Current dependencies:
# - openpyxl (Excel manipulation)
# - python-pptx (PowerPoint)
# - pypdf (PDF processing)
```

### Excel Formula Recalculation

Use the included `recalc.py` script for Excel files:

```bash
python /Users/apple/.gemini/skills/recalc.py <excel_file.xlsx> [timeout_seconds]
```

Automatically configures LibreOffice on first run for formula calculation.

---

## 📊 System Statistics

- **Last Audit**: January 21, 2026
- **Total Directories**: 260
- **Active Skills** (with SKILL.md): 252
- **Supporting Files**: 
  - `LICENSE.txt` - License information
  - `requirements.txt` - Python dependencies
  - `recalc.py` - Excel calculation utility
  - `reference.md` - PDF processing reference
  - Additional standalone markdown files for specialized features

---

## 📚 Reference Documentation

### Official Sources
- [Anthropic Skills](https://github.com/anthropic/skills) - Official Anthropic skills
- [Vercel Agent Skills](https://github.com/vercel-labs/agent-skills) - Vercel's skill library
- [Automattic Agent Skills](https://github.com/Automattic/agent-skills) - WordPress/Automattic skills

### Community Projects
- [UI/UX Pro Max Skills](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) - Advanced design skills
- [Superpowers](https://github.com/obra/superpowers) - Power user capabilities
- [Planning with Files](https://github.com/OthmanAdi/planning-with-files) - Manus-style planning
- [NotebookLM Skill](https://github.com/PleasePrompto/notebooklm-skill) - NotebookLM integration
- [Awesome Skills Collection](https://github.com/sickn33/antigravity-awesome-skills) - 200+ curated skills

---

## 🆘 Troubleshooting

### Skill Not Working?

1. **Check if SKILL.md exists**: Each skill directory must have a `SKILL.md` file
2. **Verify file permissions**: Ensure files are readable
3. **Check dependencies**: Some skills require Python packages or system tools
4. **Review skill description**: Some skills have specific prerequisites

### Adding New Skills

```bash
# Create new skill directory
mkdir /Users/apple/.gemini/skills/my-new-skill

# Create SKILL.md with YAML frontmatter
cat > /Users/apple/.gemini/skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: "Brief description of what this skill does"
---

# Skill Instructions

Detailed instructions for using this skill...
EOF
```

---

## 📝 License

See `LICENSE.txt` for licensing information. Most skills use permissive open-source licenses (MIT, Apache 2.0), but review individual skill licenses for specifics.

---

**Maintained by**: Your local Antigravity/Gemini environment  
**For questions**: Refer to skill-specific SKILL.md files or community documentation
