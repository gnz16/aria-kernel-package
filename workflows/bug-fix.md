---
description: Systematic approach to fixing bugs with root cause analysis
---

1. **Root cause investigation**
   - Analyze error logs, behavior, and code to identify the exact cause of the bug.

2. **Create bug-fix branch**
   - Switch to a new git branch for isolated debugging and fixing.

3. **Write failing test reproducing bug**
   - Create a test case that definitively fails due to the identified bug.

4. **Implement minimal fix**
   - Apply the simplest possible code change that resolves the bug and makes the test pass.

5. **Verify fix & regression testing**
   - Run the full test suite to ensure the fix is correct and hasn't introduced new issues.
