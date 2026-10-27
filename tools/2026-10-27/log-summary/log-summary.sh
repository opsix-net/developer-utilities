#!/usr/bin/env bash
# log-summary: Count log severity and pattern matches without copying sensitive log messages.
# Published 2026-10-27. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Count log severity and pattern matches without copying sensitive log messages.')
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 application log")
    parser.add_argument("--pattern", default=r"ERROR|CRITICAL|FATAL", help="Regular expression to count, case insensitive")
    args = parser.parse_args()
    import re
    from collections import Counter
    try:
        pattern = re.compile(args.pattern, re.I)
    except re.error as error:
        raise ValueError("invalid search regular expression") from error
    severity = re.compile(r"\b(DEBUG|INFO|WARN|WARNING|ERROR|CRITICAL|FATAL)\b", re.I)
    counts, lines, matched = Counter(), 0, 0
    with args.file.open(encoding="utf-8", errors="replace") as handle:
        for line in handle:
            lines += 1
            match = severity.search(line)
            if match:
                label = match.group(1).upper()
                counts["WARN" if label == "WARNING" else label] += 1
            matched += bool(pattern.search(line))
    result = {"lines": lines, "severity_counts": dict(sorted(counts.items())), "matching_lines": matched}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
