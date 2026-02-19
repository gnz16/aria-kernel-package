---
description: Complete workflow for developing new features with TDD and best practices
---

1. **Refine feature requirements**
   - Use brainstorming techniques to clarify the feature scope and success criteria.

2. **Create implementation plan**
   - Generate an `implementation_plan.md` artifact detailing the proposed changes.

3. **Create isolated feature branch**
   - Use `git` to create a new branch for the feature to maintain a clean workspace.

4. **Write failing tests first**
   - Implement initial tests that define the expected behavior. These tests should fail initially (RED phase).

5. **Build frontend (if applicable)**
   - Develop React components and styles following project best practices.

6. **Build API (if applicable)**
   - Implement backend endpoints and business logic.

7. **Create E2E tests**
   - Use Playwright to create end-to-end browser tests for the feature.

8. **Final validation**
   - Verify that all tests pass (GREEN phase), documentation is updated, and the code follows standards.
