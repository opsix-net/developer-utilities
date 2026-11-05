## Overview

`log-summary.sh` counts recognized severity labels and lines matching a regular expression. Its JSON output contains aggregate counts, not copied log messages. This makes it useful for an initial reliability or research-data triage step when message contents may contain sensitive details. Counts are descriptive signals, not diagnoses, evidence of causation, or statistical significance.

The design connects to computational thinking: logs are treated as observations, a pattern is a rule for classifying lines, and the summary is a compact output. This utility is an engineering application of those ideas; the book section does not specify this tool.

## Requirements

Use Bash to launch the script and Python 3 to perform the analysis. The Python algorithm is self-contained and has no third-party dependencies. Runtime requirements beyond these are documented in the project README.

## Input and launch

Provide a UTF-8 text log, one record per line. The script opens the file as UTF-8 and replaces invalid byte sequences rather than failing on them. Run the exact CLI command:

```bash
bash log-summary.sh --file application.log
```

The required `--file` argument names the input. An optional `--pattern` argument accepts a Python regular expression to count matching lines, case insensitively. Its default is `ERROR|CRITICAL|FATAL`. For example:

```bash
bash log-summary.sh --file application.log --pattern 'timeout|retry'
```

A malformed regular expression or an input-file error is reported through the command-line parser as an error.

## Output and interpretation

The script prints indented JSON with three fields:

- `lines`: number of lines read.
- `severity_counts`: counts of the first recognized severity label per line, with keys sorted. Recognized labels are `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `CRITICAL`, and `FATAL`. `WARNING` is normalized to `WARN`.
- `matching_lines`: number of lines that match the selected pattern at least once.

Severity recognition is case-insensitive and uses whole-word matches. Only the first severity label found on each line is counted. Pattern matches are also counted per line, not per occurrence. A line may contribute to both a severity count and `matching_lines`.

## Algorithm and limits

The script reads the file one line at a time, applies a severity search and a regular-expression search, and accumulates counters. For $n$ input characters and a fixed set of expressions, processing is linear in the input size in ordinary cases; memory use is bounded by the counters and the current line, aside from any memory used internally by regular-expression processing. Pathological regular expressions can take much longer than linear time.

The report omits message text, but the input file is still read locally and the tool does not redact or secure that file. Severity labels are recognized only when they match the listed vocabulary; custom levels are ignored. Counts alone do not establish incident severity, system health, or the reason events occurred. Review the pattern for the log format, protect source logs appropriately, and combine counts with relevant operational context.

## Reproducible setup and checks

```bash
bash log-summary.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Computational Thinking_ A Beginner’s Guide to Problem-Solving and Programming, 231 COMPUTATIONAL THINKING. The implementation is an independently written practical utility.
