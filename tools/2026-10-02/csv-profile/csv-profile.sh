#!/usr/bin/env bash
# csv-profile: Profile missing values, row shape, and numeric statistics in a CSV file.
# Published 2026-10-02. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Profile missing values, row shape, and numeric statistics in a CSV file.')
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 CSV with a unique header row")
    args = parser.parse_args()
    import csv, math
    with args.file.open(encoding="utf-8-sig", newline="") as handle:
        rows = csv.reader(handle)
        header = next(rows, [])
        if not header or len(set(header)) != len(header) or any(not name.strip() for name in header):
            raise ValueError("CSV requires nonempty, unique column names")
        stats = {field: {"missing": 0, "numeric_count": 0, "numeric_sum": 0.0, "numeric_min": None, "numeric_max": None} for field in header}
        count, ragged = 0, []
        for number, row in enumerate(rows, 2):
            count += 1
            if len(row) != len(header):
                ragged.append(number)
                continue
            for field, value in zip(header, row):
                item = stats[field]
                if not value.strip():
                    item["missing"] += 1
                    continue
                try:
                    value = float(value)
                except ValueError:
                    continue
                if not math.isfinite(value):
                    continue
                item["numeric_count"] += 1
                item["numeric_sum"] += value
                item["numeric_min"] = value if item["numeric_min"] is None else min(item["numeric_min"], value)
                item["numeric_max"] = value if item["numeric_max"] is None else max(item["numeric_max"], value)
    for item in stats.values():
        total = item.pop("numeric_sum")
        item["numeric_mean"] = total / item["numeric_count"] if item["numeric_count"] else None
    result = {"ok": not ragged, "rows": count, "ragged_rows": ragged, "columns": stats}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
