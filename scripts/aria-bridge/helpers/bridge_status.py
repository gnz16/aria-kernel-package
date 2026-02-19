#!/usr/bin/env python3
"""Display token ledger summary for ARIA Bridge.
Usage: bridge_status.py <ledger_path>
"""
import json
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: bridge_status.py <ledger_path>", file=sys.stderr)
        sys.exit(1)

    ledger_path = sys.argv[1]

    try:
        with open(ledger_path) as f:
            data = json.load(f)
        sessions = data.get("total_sessions", 0)
        saved = data.get("total_tokens_saved", 0)
        print(f"  Sessions: {sessions} | Tokens saved: {saved}")
    except (FileNotFoundError, json.JSONDecodeError):
        print("  (no ledger or invalid format)")

if __name__ == "__main__":
    main()
