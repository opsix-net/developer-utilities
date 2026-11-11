## Matrix Audit

`matrix-audit` is a small command-line utility for checking exact matrix rank, pivot columns, and determinant. It is useful when a researcher or engineer needs to establish whether a square system is singular, identify independent columns, or validate a small matrix supplied by another tool. Central place theory motivates a practical modeling habit: make assumptions explicit and test the structure of a model before trusting its output. This utility supports that habit for matrix inputs; it does not implement or solve a location model, and the book does not specify this tool.

### Prerequisites and launch

The launcher is Bash and runs Python 3. It uses only Python’s standard library, including `fractions.Fraction`; no third-party packages are required. From a shell with the script available:

```bash
bash matrix-audit.sh --matrix '[[1,2],[3,4]]'
```

The `--matrix` argument is required and takes a JSON matrix. Entries can be JSON numbers or strings representing integers or rational values, for example `"3/7"`. The input must have 1 to 100 rows and 1 to 100 columns, and every row must have the same number of entries. The string form of each parsed entry is limited to 80 characters. Booleans are rejected. Values are converted with `Fraction(str(value))`. JSON integers and strings are interpreted exactly after parsing; JSON decimal or exponent numbers are first parsed as Python floats, so use strings to preserve their exact decimal or rational values. The calculation then uses exact rational arithmetic, not floating-point tolerance-based analysis.

### Reading the result

The example returns JSON fields for row and column counts, rank, zero-based pivot-column indices, determinant, singularity, and the arithmetic label. Its matrix has rank 2, pivot columns `[0,1]`, determinant `-2`, and `singular: false`. Pivot indices start at zero. For a square matrix, `singular` is true when rank is less than the number of columns, and the determinant is returned as a rational string. For a rectangular matrix, determinant and singularity are `null`, because those square-matrix properties do not apply. Rank-deficient square matrices receive determinant `0`.

### Method and limitations

The implementation performs forward Gaussian elimination over exact rational numbers. It scans columns from left to right, selects the first available nonzero pivot row, swaps rows when needed, and eliminates entries below each pivot. The pivot columns it records form a basis for the matrix’s column space. For an $m$ by $n$ matrix, the elimination takes on the order of $mn\min(m,n)$ rational arithmetic operations, with additional cost from growing integer numerators and denominators. Exactness avoids rounding-based rank decisions, but intermediate fractions can become large.

The tool reports algebraic properties only. It does not assess measurement error, conditioning, scientific significance, or whether a matrix correctly represents a real system. The size and entry-length caps are concrete input limits, not a promise that every matrix within them will run quickly. Malformed JSON, ragged matrices, invalid values, and violated limits are reported as command-line errors. Use a numerically appropriate method and domain review when the data are approximate measurements or the matrix is too large for exact rational elimination.

## Reproducible setup and checks

```bash
bash matrix-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Discrete Diversity and Dispersion Maximization _ A Tutorial -- Rafael Martí, Anna Martínez-Gavara, (eds_) -- Springer, 2.4 Central Place Theory. The implementation is an independently written practical utility.
