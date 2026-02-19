# Skill Manager - Reference Guide

## Complete Skill Categories

### Development Workflow (14 skills)
Skills that manage the software development lifecycle from idea to deployment.

- **brainstorming** - Interactive design refinement before coding
- **writing-plans** - Create detailed implementation plans
- **executing-plans** - Execute plans in batches with checkpoints
- **subagent-driven-development** - Autonomous task execution with review
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **git-worktrees** - Parallel development branches
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **finishing-a-development-branch** - Branch completion workflow
- **using-superpowers** - Superpowers system guide
- **writing-skills** - Create new skills
- **verification-before-completion** - Ensure fixes work
- **project-guidelines** - Project-specific guidelines
- **tdd-workflow** - TDD methodology

### Testing & Quality (5 skills)
Skills for testing, debugging, and ensuring code quality.

- **test-driven-development** - RED-GREEN-REFACTOR TDD enforcement
- **ui-testing** - Playwright E2E testing framework
- **webapp-testing** - Web application testing
- **systematic-debugging** - 4-phase root cause analysis
- **security-review** - Security audit workflows

### Frontend Development (4 skills)
Skills for React, UI/UX, and frontend optimization.

- **react-best-practices** - React/Next.js optimization (Vercel, 45 rules)
- **frontend-patterns** - React component patterns
- **frontend-design** - Frontend design patterns
- **web-design-guidelines** - UI/UX compliance (Vercel, 100+ rules)

### Backend Development (3 skills)
Skills for backend architecture and API design.

- **backend-patterns** - Backend architecture patterns
- **mcp-builder** - MCP server generation (Anthropic official)
- **clickhouse-io** - ClickHouse analytics patterns

### Code Quality (2 skills)
Skills for code standards and verification.

- **coding-standards** - Universal coding standards
- **verification-before-completion** - Fix verification

### Document Creation (5 skills)
Official Anthropic skills for document generation.

- **docx** - Microsoft Word documents
- **pdf** - PDF operations
- **pptx** - PowerPoint presentations
- **xlsx** - Excel spreadsheets
- **doc-coauthoring** - Collaborative document creation

### Creative & Design (6 skills)
Skills for creative work and design.

- **algorithmic-art** - Algorithmic visualizations
- **canvas-design** - Canvas/graphic design
- **theme-factory** - Theme generation
- **brand-guidelines** - Brand consistency
- **slack-gif-creator** - Slack GIF generation
- **web-artifacts-builder** - Web artifact generation

### Enterprise & Communication (2 skills)
Skills for enterprise workflows.

- **internal-comms** - Internal communications
- **skill-creator** - Custom skill creation

---

## Workflow Templates

### Complete Feature Development
```
1. brainstorming → Design & requirements
2. writing-plans → Implementation plan
3. git-worktrees → Isolated workspace
4. test-driven-development → TDD approach
5. subagent-driven-development → Auto-execute tasks
6. systematic-debugging → Debug issues
7. requesting-code-review → Pre-review checklist
8. finishing-a-development-branch → Merge/PR workflow
```

### React Application
```
1. brainstorming → Architecture design
2. react-best-practices → Optimization guidelines
3. frontend-patterns → Component patterns
4. web-design-guidelines → UI/UX compliance
5. test-driven-development → Write tests
6. ui-testing → E2E testing
```

### Documentation Suite
```
1. docx → Project specification
2. pptx → Presentation slides
3. xlsx → Data/calculations
4. pdf → Final reports
5. brand-guidelines → Consistency check
```

### API Development
```
1. backend-patterns → API design
2. mcp-builder → MCP integration (if needed)
3. test-driven-development → TDD approach
4. security-review → Security audit
5. systematic-debugging → Debug issues
```

---

## Skill Sources

| Repository | Skills | Focus |
|------------|--------|-------|
| everything-claude-code | 7 | Coding patterns from hackathon winner |
| vercel-labs/agent-skills | 2 | React optimization + UI/UX |
| obra/superpowers | 14 | Complete dev workflow |
| anthropics/skills | 16 | Official (documents, MCP, creative) |
| Custom | 1 | ui-testing framework |
| **Total** | **40+** | **Complete coverage** |

---

## Quick Reference

**Most Used Workflows:**
- Feature development: 8 skills
- Debugging: 3 skills  
- Testing: 5 skills
- Frontend: 4 skills
- Backend: 3 skills
- Documents: 5 skills

**By Priority:**
- Critical: TDD, debugging, code review
- High: React optimization, backend patterns
- Medium: Design guidelines, git workflows
- Low: Creative tools, communications
