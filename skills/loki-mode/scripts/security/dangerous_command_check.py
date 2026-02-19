#!/usr/bin/env python3
"""
Dangerous Command Check - Security utility to detect dangerous shell commands.

Usage:
    python dangerous_command_check.py "command to check"
    
    # Or via stdin (JSON format):
    echo '{"command": "rm -rf /"}' | python dangerous_command_check.py
    
Exit Codes:
    0 - Command is safe
    2 - Command is BLOCKED (dangerous)
"""

import json
import sys
import re


DANGEROUS_PATTERNS = [
    r'\brm\s+.*-[a-z]*r[a-z]*f',     # rm -rf, rm -fr, rm -Rf, etc.
    r'\brm\s+.*-[a-z]*f[a-z]*r',     # rm -fr variations
    r'\brm\s+--recursive\s+--force', # rm --recursive --force
    r'\brm\s+--force\s+--recursive', # rm --force --recursive
    r'\brm\s+-r\s+.*-f',             # rm -r ... -f
    r'\brm\s+-f\s+.*-r',             # rm -f ... -r
    r'sudo\s+rm',                     # sudo rm commands
    r'chmod\s+777',                   # Dangerous permissions
    r'>\s*/etc/',                     # Writing to system directories
    r':\(\)\s*{\s*:\s*\|',           # Fork bomb
    r'dd\s+.*of=/dev/[sh]d',         # dd to disk device
]

DANGEROUS_PATHS = [
    r'^/$',          # Root directory
    r'^/\*$',        # Root with wildcard
    r'^~/?$',        # Home directory
    r'^\$HOME/?$',   # Home environment variable
    r'\.\.',         # Parent directory references
    r'^\*$',         # Just wildcard
    r'^\.$',         # Current directory alone
]


def is_dangerous_rm_command(command: str) -> bool:
    """
    Comprehensive detection of dangerous rm commands.
    """
    normalized = ' '.join(command.lower().split())
    
    # Check for dangerous patterns
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, normalized, re.IGNORECASE):
            return True
    
    # Check for rm with recursive flag targeting dangerous paths
    if re.search(r'\brm\s+.*-[a-z]*r', normalized):
        for path_pattern in DANGEROUS_PATHS:
            if re.search(path_pattern, normalized):
                return True
    
    return False


def main():
    command = None
    
    # Check command line argument first
    if len(sys.argv) > 1:
        command = ' '.join(sys.argv[1:])
    else:
        # Try reading from stdin (JSON format)
        try:
            if not sys.stdin.isatty():
                input_data = json.load(sys.stdin)
                command = input_data.get('command', '')
        except (json.JSONDecodeError, ValueError):
            pass
    
    if not command:
        print("Usage: python dangerous_command_check.py 'command'", file=sys.stderr)
        print("   or: echo '{\"command\": \"...\"}' | python dangerous_command_check.py", file=sys.stderr)
        sys.exit(1)
    
    if is_dangerous_rm_command(command):
        print(f"BLOCKED: Dangerous command detected: {command}", file=sys.stderr)
        sys.exit(2)
    
    print(f"SAFE: {command}")
    sys.exit(0)


if __name__ == '__main__':
    main()
