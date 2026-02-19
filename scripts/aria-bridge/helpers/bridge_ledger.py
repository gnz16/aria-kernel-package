#!/usr/bin/env python3
"""Token ledger updater for ARIA Bridge.
Usage: bridge_ledger.py <ledger_path> <read_mode>
  read_mode: 'delta' or 'full'
"""
import json
import sys
import datetime

def main():
    if len(sys.argv) < 3:
        print("Usage: bridge_ledger.py <ledger_path> <read_mode>", file=sys.stderr)
        sys.exit(1)

    ledger_path = sys.argv[1]
    mode = sys.argv[2]

    try:
        with open(ledger_path) as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return

    tokens_per_full = data.get("tokens_per_full_read", 400)
    data.setdefault("sessions", []).append({
        "timestamp": datetime.datetime.now().isoformat(),
        "read_mode": mode,
        "tokens_saved": tokens_per_full if mode == "delta" else 0,
    })
    data["total_sessions"] = len(data["sessions"])
    data["total_tokens_saved"] = sum(s.get("tokens_saved", 0) for s in data["sessions"])

    with open(ledger_path, "w") as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    main()
