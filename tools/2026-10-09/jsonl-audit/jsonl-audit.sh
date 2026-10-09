#!/usr/bin/env bash
# jsonl-audit: Audit JSON Lines validity and field type consistency without exposing record values.
# Published 2026-10-09. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Audit JSON Lines validity and field type consistency without exposing record values.')
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 JSON Lines file")
    args = parser.parse_args()
    from collections import Counter, defaultdict
    types = defaultdict(Counter)
    present = Counter()
    records, errors = 0, []
    with args.file.open(encoding="utf-8") as handle:
        for number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except ValueError:
                errors.append({"line": number, "error": "invalid JSON"})
                continue
            if not isinstance(record, dict):
                errors.append({"line": number, "error": "expected an object"})
                continue
            records += 1
            for field, value in record.items():
                present[field] += 1
                types[field][type(value).__name__] += 1
    result = {"ok": not errors, "valid_records": records, "invalid_lines": errors,
              "fields": {field: {"types": dict(types[field]), "missing": records - present[field]} for field in sorted(types)}}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
