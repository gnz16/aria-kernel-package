#!/usr/bin/env python3
"""
Environment File Guard - Prevents access to .env files containing sensitive data.

Usage:
    python env_file_guard.py "file_path_or_command"
    
    # Or via stdin (JSON format):
    echo '{"file_path": ".env", "command": "cat .env"}' | python env_file_guard.py
    
Exit Codes:
    0 - Access is safe
    2 - Access is BLOCKED (.env file detected)
"""

import json
import sys
import re


ENV_COMMAND_PATTERNS = [
    r'cat\s+.*\.env\b(?!\.sample)',      # cat .env
    r'less\s+.*\.env\b(?!\.sample)',     # less .env
    r'more\s+.*\.env\b(?!\.sample)',     # more .env
    r'head\s+.*\.env\b(?!\.sample)',     # head .env
    r'tail\s+.*\.env\b(?!\.sample)',     # tail .env
    r'echo\s+.*>\s*\.env\b(?!\.sample)', # echo > .env
    r'touch\s+.*\.env\b(?!\.sample)',    # touch .env
    r'cp\s+.*\.env\b(?!\.sample)',       # cp .env
    r'mv\s+.*\.env\b(?!\.sample)',       # mv .env
    r'vim\s+.*\.env\b(?!\.sample)',      # vim .env
    r'nano\s+.*\.env\b(?!\.sample)',     # nano .env
    r'code\s+.*\.env\b(?!\.sample)',     # code .env
]


def is_env_file(file_path: str) -> bool:
    """Check if a file path references a .env file (not .env.sample)."""
    if not file_path:
        return False
    return '.env' in file_path and not file_path.endswith('.env.sample')


def is_env_command(command: str) -> bool:
    """Check if a command tries to access .env files."""
    if not command:
        return False
    for pattern in ENV_COMMAND_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False


def main():
    file_path = None
    command = None
    
    # Check command line argument first
    if len(sys.argv) > 1:
        arg = ' '.join(sys.argv[1:])
        # Treat as both file path and command
        file_path = arg
        command = arg
    else:
        # Try reading from stdin (JSON format)
        try:
            if not sys.stdin.isatty():
                input_data = json.load(sys.stdin)
                file_path = input_data.get('file_path', '')
                command = input_data.get('command', '')
        except (json.JSONDecodeError, ValueError):
            pass
    
    if not file_path and not command:
        print("Usage: python env_file_guard.py 'file_path_or_command'", file=sys.stderr)
        print("   or: echo '{\"file_path\": \"...\", \"command\": \"...\"}' | python env_file_guard.py", file=sys.stderr)
        sys.exit(1)
    
    if is_env_file(file_path):
        print(f"BLOCKED: Access to .env file prohibited: {file_path}", file=sys.stderr)
        print("Use .env.sample for template files instead", file=sys.stderr)
        sys.exit(2)
    
    if is_env_command(command):
        print(f"BLOCKED: Command accesses .env file: {command}", file=sys.stderr)
        print("Use .env.sample for template files instead", file=sys.stderr)
        sys.exit(2)
    
    print(f"SAFE: {file_path or command}")
    sys.exit(0)


if __name__ == '__main__':
    main()
