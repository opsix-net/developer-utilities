#!/usr/bin/env bash
# matrix-audit: Compute exact matrix rank, pivot columns, and determinant from JSON.
# Published 2026-11-11. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Compute exact matrix rank, pivot columns, and determinant from JSON.')
try:
    parser.add_argument("--matrix", required=True, help="JSON square or rectangular matrix; rationals may be strings")
    args = parser.parse_args()
    from fractions import Fraction
    raw = json.loads(args.matrix)
    if not isinstance(raw, list) or not raw or len(raw) > 100 or any(not isinstance(row, list) for row in raw):
        raise ValueError("matrix must contain 1 to 100 rows")
    columns = len(raw[0])
    if not 1 <= columns <= 100 or any(len(row) != columns for row in raw):
        raise ValueError("matrix must be rectangular with 1 to 100 columns")
    if any(len(str(value)) > 80 or isinstance(value, bool) for row in raw for value in row):
        raise ValueError("matrix entries must be bounded numeric or rational values")
    matrix = [[Fraction(str(value)) for value in row] for row in raw]
    rank, sign, pivots, product = 0, 1, [], Fraction(1)
    for column in range(columns):
        pivot = next((row for row in range(rank, len(matrix)) if matrix[row][column]), None)
        if pivot is None:
            continue
        if pivot != rank:
            matrix[rank], matrix[pivot] = matrix[pivot], matrix[rank]
            sign *= -1
        value = matrix[rank][column]
        product *= value
        for row in range(rank + 1, len(matrix)):
            factor = matrix[row][column] / value
            for j in range(column, columns):
                matrix[row][j] -= factor * matrix[rank][j]
        pivots.append(column)
        rank += 1
        if rank == len(matrix):
            break
    square = len(matrix) == columns
    result = {"rows": len(matrix), "columns": columns, "rank": rank, "pivot_columns_zero_based": pivots,
              "determinant": str(sign * product if rank == columns else Fraction(0)) if square else None,
              "singular": rank < columns if square else None, "arithmetic": "exact rational"}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
