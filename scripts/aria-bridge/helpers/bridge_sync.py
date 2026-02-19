#!/usr/bin/env python3
"""Sync project-state.md with updated Active Tasks section.
Usage: bridge_sync.py <state_file> <agent> <active_section_text>
"""
import re
import sys
import datetime

def main():
    if len(sys.argv) < 4:
        print("Usage: bridge_sync.py <state_file> <agent> <active_section>", file=sys.stderr)
        sys.exit(1)

    state_file = sys.argv[1]
    agent = sys.argv[2]
    new_active = sys.argv[3]

    try:
        with open(state_file, "r") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: {state_file} not found", file=sys.stderr)
        sys.exit(1)

    # Replace Active Tasks block
    content = re.sub(
        r'## Active Tasks\n.*?(?=\n## |\Z)',
        new_active + "\n",
        content,
        flags=re.DOTALL,
    )

    # Update last-modified line
    now = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S%z')
    content = re.sub(
        r'\*Last updated by:.*\*',
        f'*Last updated by: {agent} | {now}*',
        content,
    )

    with open(state_file, "w") as f:
        f.write(content)

    print("project-state.md updated")

if __name__ == "__main__":
    main()
