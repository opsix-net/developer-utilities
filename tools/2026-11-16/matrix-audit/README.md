## matrix-audit

`matrix-audit` computes the exact rank, zero-based pivot columns, and determinant (for square matrices) of a matrix supplied as JSON. It is a small scientific-computing and engineering diagnostic, not a predictive-model evaluation tool. Rank can reveal linearly dependent columns in a design or constraint matrix; the determinant reports whether a square matrix is singular. Neither result establishes that a scientific model is valid or that a numerical workflow is otherwise well-conditioned.

### Requirements and launch

The launcher is Bash and runs Python 3. The Python algorithm uses only the standard library, including `fractions.Fraction`; there are no third-party dependencies. Set `PYTHON_BIN` if Python 3 is available under a non-default executable name.

```bash
bash matrix-audit.sh --matrix '[[1,2],[3,4]]'
```

The required `--matrix` argument is a JSON array of rows. The input may be square or rectangular, must have 1 to 100 rows and 1 to 100 columns, and every row must have the same length. Entries are converted using Python's `Fraction`. Integers and rational strings such as `"1/3"` retain exact values; JSON fractional numbers are parsed as floats before conversion, so use rational strings when exact decimal or rational input matters. Quote the JSON argument so the shell passes it intact.

### Reading output

The example returns two rows and two columns, rank 2, pivot columns `[0, 1]`, determinant `-2`, `singular: false`, and `arithmetic: "exact rational"`. Pivot indices are zero-based. For a rectangular matrix, `determinant` and `singular` are `null`, because these properties are reported only for square matrices. A square matrix is marked singular when its rank is less than its number of columns. Results are printed as JSON.

The algorithm scans columns from left to right, selects the first nonzero available pivot, swaps rows when necessary, and eliminates entries below each pivot using exact fractions. The pivot count gives rank, and the product of pivots adjusted for row-swap sign gives the determinant when the square matrix has full rank. With at most 100 rows and columns, elimination has cubic-order arithmetic-operation growth in the square case, approximately $O(n^3)$. Exact rational numerators and denominators can grow, so bit-level cost is not captured by that operation count.

### Limits and workflow fit

Malformed JSON, ragged rows, empty or oversized dimensions, Boolean entries, and entries whose string representation exceeds 80 characters are rejected. Values must be accepted by `Fraction`; arbitrary symbolic expressions are not supported. The input is bounded by dimensions and entry-string length, but very large rational intermediates may still be computationally expensive. The program does not compute eigenvalues, condition numbers, approximate floating-point diagnostics, or statistical metrics.

In a research pipeline, run this audit on a small exact design or constraint matrix before passing it into a larger calculation. Exact rank can expose redundant columns, while a zero determinant identifies a singular square system. This complements model evaluation: prediction metrics describe performance against test labels, whereas matrix properties describe algebraic structure. The book topic motivates careful, question-specific diagnostics, but the book does not specify this utility.

## Reproducible setup and checks

```bash
bash matrix-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** PRACTITIONERS GUIDE TO DATA SCIENCE - streamlining data -- Mirza, Nasir Ali;, 8 A clustering algorithm. The implementation is an independently written practical utility.
