## Purpose

`log-summary.sh` counts recognized severity labels and lines matching a regular expression. It prints aggregate JSON rather than copying log messages into its output. This is useful when a researcher, on-call engineer, or pipeline maintainer needs a quick overview of an application log without pasting potentially sensitive records into a report or notebook.

The design idea behind the workflow is to keep responsibilities clear: read lines, classify severity, test the search pattern, and emit a summary. This book topic motivates thinking explicitly about component responsibilities and readable interfaces. It does not specify this utility or its implementation.

## Prerequisites and input

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. The input must be a readable UTF-8 text log. Invalid UTF-8 byte sequences are replaced during decoding, so they do not stop the scan, but replacement can affect text matching. The program reads the file line by line.

Each line is checked for the first recognized severity token: `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `CRITICAL`, or `FATAL`. Matching is case-insensitive and uses word boundaries. Labels are reported in uppercase, with `WARNING` normalized to `WARN`. Separately, a regular expression is tested against each line. The default expression is `ERROR|CRITICAL|FATAL`; pattern matching is case-insensitive. A line contributes at most once to `matching_lines`, even if its pattern has multiple matches.

## Launch

```bash
bash log-summary.sh --file application.log
```

To select another regular expression, use the supported `--pattern` option, for example:

```bash
bash log-summary.sh --file application.log --pattern 'timeout|connection reset'
```

The pattern follows Python regular-expression syntax. The `--file` option is required. The tool accepts no claim that a match is a unique event or a root cause.

## Output and algorithm

The program prints formatted JSON with three fields: `lines` is the number of lines read; `severity_counts` is an alphabetically ordered mapping of recognized severity labels to counts; `matching_lines` is the number of lines matched by the selected expression. Severity classification and pattern matching are independent, so one line can contribute to both summaries. Errors such as an unreadable file or an invalid regular expression are reported through the command-line parser as errors.

For a file of $n$ lines and total text size $N$ characters, the scan takes $O(N)$ time, with regex cost dependent on the expression and input. It stores counters and the current line rather than the entire file, so working memory is bounded by the longest line plus the small result structure, apart from regex-engine details.

## Limits and safe interpretation

The utility counts only the first recognized severity token per line. Lines without a recognized token do not appear in `severity_counts`. Pattern results count lines, not occurrences. Counts are descriptive summaries: they do not establish statistical significance, causation, or that the logging format captured every event. Review the pattern and severity vocabulary against the application's actual format. The program avoids copying messages into its output, but it does read the source file, so protect the file and execution environment according to your data-handling requirements.

## Reproducible setup and checks

```bash
bash log-summary.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Structures and Algorithms in C++ 2e, 56 Chapter 1. A C++ Primer. The implementation is an independently written practical utility.
