#!/bin/bash

# Security Guardrails Master Script for APPM
# Integrates dangerous command checks and environment file protection.

COMMAND="$1"
FILE_PATH="$2"

SKILLS_DIR="/Users/apple/.gemini/skills/claude-code-hooks-mastery/scripts/security"

# 1. Dangerous Command Check
if [ -n "$COMMAND" ]; then
    python3 "$SKILLS_DIR/dangerous_command_check.py" "$COMMAND"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo "🚨 SECURITY ALERT: Dangerous command blocked by APPM Guardrails."
        exit 2
    fi
fi

# 2. Environment File Guard
if [ -n "$FILE_PATH" ]; then
    python3 "$SKILLS_DIR/env_file_guard.py" "$FILE_PATH" "$COMMAND"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 2 ]; then
        echo "🚨 SECURITY ALERT: Sensitive file access blocked by APPM Guardrails."
        exit 2
    fi
fi

echo "✅ Security checks passed."
exit 0
