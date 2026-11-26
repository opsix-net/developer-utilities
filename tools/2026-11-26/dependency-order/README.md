## dependency-order

`dependency-order` reads a JSON dependency graph, returns a deterministic topological order when possible, and flags nodes blocked by cycles. It is useful when a research or engineering workflow has prerequisites that must finish before downstream tasks begin. For example, a market-data pipeline may require ingestion before validation, validation before feature generation, and feature generation before backtesting. The book topic motivates the workflow design, but this utility is a general dependency checker, not a financial-analysis tool.

### Requirements

Run the Bash script in an environment with Bash and Python 3. It uses only Python's standard library and has no third-party dependencies. The script launches `${PYTHON_BIN:-python3}`; set `PYTHON_BIN` if Python 3 is available under a different command.

### Input

Provide a UTF-8 JSON file containing an object that maps each task name to a list of its dependencies. For example:

```json
{
  "ingest": [],
  "validate": ["ingest"],
  "features": ["validate"],
  "backtest": ["features"]
}
```

A dependency named in a list does not need its own object key. It is still treated as a node, with no dependencies of its own unless specified in the object. Task names and dependency names must be strings, and each dependency value must be a list of strings.

### Run

```bash
bash dependency-order.sh --file dependencies.json
```

### Read the result

The tool prints JSON with `ok`, `topological_order`, `blocked_nodes`, and `nodes`. `ok` is `true` when all nodes can be ordered and `false` when some nodes remain blocked by a cycle. `topological_order` contains the tasks emitted by the algorithm. When several tasks are ready at once, it selects the lexicographically smallest available name, making the result deterministic for the same graph. `blocked_nodes` is the sorted set of nodes not emitted. `nodes` is the number of distinct tasks, including dependencies that appeared only in lists.

A cyclic graph produces its JSON result and exits with status 1. A valid acyclic graph exits successfully. File, JSON, or input-shape errors are reported through the command-line parser as errors.

### Algorithm and limits

The implementation uses Kahn's topological-sort algorithm. It tracks each node's remaining prerequisites, queues nodes with none, and releases dependents as prerequisites are removed. A heap provides deterministic selection among ready nodes. With $V$ distinct nodes and $E$ dependency relationships, the core algorithm is $O((V+E)\log V)$ in this implementation, including ordered queue operations; memory use is $O(V+E)$.

The tool checks graph orderability, not whether tasks succeed, whether dependencies are semantically correct, or whether a schedule is optimal. It does not execute tasks, infer missing relationships, validate task names against a project, or report a cycle path. A blocked node can be part of a cycle or depend on a node that is part of one. Keep the input graph accurate, and use the result as a scheduling aid rather than a substitute for workflow validation.

## Reproducible setup and checks

```bash
bash dependency-order.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Python Fundamentals for Finance- A survey of Algorithmic, Chapter 3: Python-based Market Data Analysis. The implementation is an independently written practical utility.
