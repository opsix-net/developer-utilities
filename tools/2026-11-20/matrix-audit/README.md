# matrix-audit

`matrix-audit` computes the exact rational rank, pivot columns, and determinant (when the input is square) for a matrix supplied as JSON. It is a small inspection tool for scientific computing and engineering work, such as checking whether a set of constraints or measured features contains linearly dependent columns. The automation and backtesting topic motivates the workflow: validate the structure of data used in a larger analysis before relying on downstream decisions. The book section discusses data quality and automated systems; it does not specify this utility.

## Prerequisites

Use Bash and Python 3. The Bash script launches Python 3, and the Python algorithm is self-contained. There are no third-party dependencies. If Python 3 is installed under a different command, set `PYTHON_BIN` to that executable when launching the script.

## Input and launch

Pass a JSON array of equally sized row arrays with the required `--matrix` option. Matrices may be square or rectangular. Entries are converted to exact rational values using Python's `Fraction`; rational strings such as `"1/3"` are supported. For example:

```bash
bash matrix-audit.sh --matrix '[[1,2],[3,4]]'
```

The input must contain 1 to 100 rows and 1 to 100 columns, and all rows must have the same length. Entry representations may not exceed 80 characters, and booleans are rejected. Invalid JSON, invalid matrix shapes, or values that cannot be converted to rational numbers produce an argument error.

## Reading the output

The command prints JSON containing `rows`, `columns`, `rank`, `pivot_columns_zero_based`, `determinant`, `singular`, and `arithmetic`. Pivot indices start at zero. For square matrices, `determinant` is an exact rational string and `singular` indicates whether rank is less than the number of columns. For rectangular matrices, both fields are `null`, since this tool does not report a rectangular determinant or singularity. The arithmetic field identifies the result as exact rational.

## Method and limitations

The implementation scans columns from left to right, selects the first available nonzero pivot row, swaps rows when needed, and eliminates entries below each pivot using rational arithmetic. Pivot columns and rank follow from the elimination. For a square full-rank matrix, the determinant is the product of pivot values adjusted for row-swap sign; if rank is deficient, the determinant is zero. With $m$ rows and $n$ columns, elimination takes $O(mn\min(m,n))$ arithmetic operations in the usual operation-count model. Exact fractions can grow in size, so actual runtime also depends on numerator and denominator sizes.

This tool checks linear-algebra structure only. It does not assess data quality, statistical significance, causality, predictive power, or whether a matrix is appropriate for a particular model. It has fixed size and entry-length limits, and it does not provide numerical tolerance settings because its arithmetic is exact rational arithmetic.

## Reproducible setup and checks

```bash
bash matrix-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Advanced Options Strategies, Chapter 9: Automating Trading and Backtesting. The implementation is an independently written practical utility.
