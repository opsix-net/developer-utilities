## Overview

`log-summary.sh` counts recognized severity labels and lines matching a regular expression. It prints aggregate JSON rather than copying log messages, which is useful when inspecting sensitive application logs during incident triage or research operations. The classifier-evaluation topic motivates the same careful habit: reduce observations to clearly defined counts, then interpret those counts in context. This utility is an independent log summarizer, not a feature specified by the book or a statistical classifier.

## Prerequisites

The launcher is Bash and invokes Python 3. No third-party Python packages are required. The Python algorithm is self-contained. Set `PYTHON_BIN` if Python 3 is installed under a non-default command or path. The input file must be readable by the current user.

## Input and launch

The input is a UTF-8 application log, ordinarily one event per line. Invalid UTF-8 bytes are replaced during reading. Run the exact basic command:

```bash
bash log-summary.sh --file application.log
```

An optional regular expression can be supplied with `--pattern`:

```bash
bash log-summary.sh --file application.log --pattern 'timeout|connection refused'
```

The pattern is a Python regular expression and matching is case-insensitive. Its default is `ERROR|CRITICAL|FATAL`. Because the expression is interpreted as a regular expression, escape characters that should be literal regex metacharacters.

## Output interpretation and algorithm

The tool emits formatted JSON with three fields: `lines` is the number of lines read; `severity_counts` contains counts for recognized labels; and `matching_lines` is the number of lines matching the selected pattern. Recognized severity labels are `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `CRITICAL`, and `FATAL`. Matching is case-insensitive, and `WARNING` is normalized to `WARN`. At most one severity label is counted per line: the first recognized severity match found by the severity expression is used. Pattern counts are per matching line, not per occurrence, so multiple matches on one line add only one to `matching_lines`. A line may contribute to both a severity count and the pattern count.

For $n$ input lines and total input size $b$, the script reads and scans each line once. Runtime is approximately $O(b)$, with regex costs depending on pattern and input; memory use is bounded by the current line and aggregate counters rather than the whole file. The JSON contains aggregates only, not the original message text.

## Limitations and safe use

This is a descriptive count, not an alerting, diagnosis, or causal analysis system. It does not validate a logging schema, associate multiline records, parse timestamps, deduplicate events, or infer severity when labels are absent. The first severity label wins if a line contains multiple recognized labels. Pattern matching counts lines, not occurrences. Regex behavior and pathological expressions can affect runtime. Logs can still expose sensitive information through counts or other metadata, so handle output according to local data policies. The tool does not redact or transmit input, but it also cannot guarantee that the surrounding environment is secure. File or invalid-regex errors are reported through the command-line parser rather than producing a partial summary; invalid UTF-8 bytes are replaced.

## Reproducible setup and checks

```bash
bash log-summary.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Applied Data Science Using PySpark - Learn the End-to-End -- Ramcharan Kakarla & Sundar Krishnan & Sridhar Alla, 6.4.2.3 y-hat prediction to probability to final prediction. The implementation is an independently written practical utility.
