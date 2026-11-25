# matrix-audit

`matrix-audit` computes the exact matrix rank, pivot columns, and determinant (for square matrices) from JSON input. It is a small validation aid for scientific computing and engineering workflows, including checks of hand-built covariance examples, linear constraints, and test fixtures before they enter a larger pipeline. The book topic motivates this workflow because multivariate risk calculations rely on covariance matrices, but the book does not specify this utility. A matrix audit is structural housekeeping, not evidence that a covariance estimate is statistically sound.

## Requirements

Run the Bash launcher with Bash and Python 3 available. The Python algorithm is self-contained and has no third-party dependencies. The launcher uses `python3` by default; set `PYTHON_BIN` to select another Python executable if needed.

## Input and launch

Pass a JSON matrix with `--matrix`. Matrices may be square or rectangular, must have 1 to 100 rows and 1 to 100 columns, and must be rectangular. Entries are converted to exact rational values. Integers and decimal strings are accepted through Python's `Fraction` parsing; rational values may be supplied as strings, such as `"1/3"`. Boolean values are rejected. Each entry's string representation is bounded to 80 characters.

```bash
bash matrix-audit.sh --matrix '[[1,2],[3,4]]'
```

For exact fractional input:

```bash
bash matrix-audit.sh --matrix '[["1/2",0],[0,"3/4"]]'
```

## Reading the output

The command prints JSON containing row and column counts, `rank`, zero-based `pivot_columns_zero_based`, `determinant`, `singular`, and `arithmetic`. For a rectangular matrix, `determinant` and `singular` are `null`, because these fields are defined here only for square matrices. For a square matrix, `singular` is true when rank is less than the number of columns. The determinant is formatted as an exact rational string.

For example, the first command produces rank 2, pivot columns `[0, 1]`, determinant `"-2"`, and `singular: false`. Pivot indices start at zero, as is common in programming interfaces.

## Method and limits

The implementation performs forward Gaussian elimination over Python `Fraction` values. It searches downward for a nonzero pivot in each column, swaps rows when needed, and tracks pivot positions and determinant sign. The product of pivots, adjusted for row swaps, gives the determinant when the matrix is square and full rank; otherwise the determinant is zero. Exact rational arithmetic avoids floating-point rounding in zero and rank decisions.

For an $m$ by $n$ dense matrix, elimination takes cubic-order work in the square case, conventionally $O(n^3)$, with rational arithmetic costs that can grow as numerators and denominators expand. The 100-row and 100-column bounds do not make every large rational input inexpensive. This tool does not check symmetry, positive definiteness, positive semidefiniteness, conditioning, units, or statistical suitability. It does not handle missing or nonfinite values as observations: entries must parse as bounded rational values, and invalid values produce an argument error. Use numerical linear algebra with appropriate tolerances for floating-point estimated matrices, and use domain-specific diagnostics for scientific interpretation.

## Reproducible setup and checks

```bash
bash matrix-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Market Risk Analysis [vol 2] - Practical Financial Econometrics.pdf, 360 Practical Financial Econometrics. The implementation is an independently written practical utility.
