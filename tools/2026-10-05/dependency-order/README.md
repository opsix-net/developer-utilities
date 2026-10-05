# Dependency Order

`dependency-order.sh` finds a deterministic topological order for named tasks and reports nodes left blocked by cyclic dependencies. It is a small check for build systems, data-cleaning pipelines, and workflow orchestration. The idea connects naturally to working with semi-structured data: once JSON, scraped content, or other inputs have been inspected, processing steps often have prerequisites. This utility organizes those declared prerequisites. It does not parse or clean the data itself, and the book topic motivates the workflow, not this particular tool.

## Prerequisites

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. Set `PYTHON_BIN` if Python 3 is available under a different executable name or path. Run the script from an environment where Bash and that interpreter are available.

## Input format

Provide a UTF-8 JSON file containing an object that maps task names to lists of dependency names. Each task name and dependency must be a string. An empty list means that the task has no prerequisites. For example:

```json
{
  "build": ["generate"],
  "generate": [],
  "test": ["build"]
}
```

A dependency name that does not appear as an object key is still included as a node, with no dependencies of its own. The tool uses sets internally, so duplicate dependency entries do not create duplicate graph edges.

## Run it

```bash
bash dependency-order.sh --file dependencies.json
```

The `--file` argument is required. The command prints formatted JSON. A successful result has `"ok": true`, a `topological_order` array, an empty `blocked_nodes` array, and a `nodes` count. Among nodes that are ready at the same point, the implementation chooses lexicographically, so the resulting order is deterministic for the same graph. If the graph contains a cycle, `ok` is false, `blocked_nodes` lists nodes not emitted into the order, and the process exits with status 1. The listed blocked nodes can include nodes downstream of a cycle, not only nodes that are themselves in a cycle. Invalid input or file errors are reported through argparse, and the command exits unsuccessfully.

## Algorithm and complexity

The implementation uses Kahn’s topological-sort method. It starts with nodes that have no remaining prerequisites, removes one ready node at a time, and makes its dependents ready when their prerequisites have all been removed. A min-heap provides deterministic lexicographic selection. With $V$ nodes and $E$ distinct dependency edges, heap operations give a time bound of $O((V+E)\log V)$, with graph storage of $O(V+E)$. Sorting dependent lists also contributes within that bound.

## Limitations

The utility checks graph structure, not task correctness, JSON payload quality, task success, resource constraints, parallel execution, retries, or data provenance. A valid order does not prove that the dependencies are complete or scientifically appropriate. Cyclic workflows that genuinely require iteration need a workflow model with explicit loop and stopping behavior, rather than a topological ordering. Review the graph and pair it with task-level validation before using its order in production.

## Reproducible setup and checks

```bash
bash dependency-order.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Python Data Cleaning Cookbook, 2 Anticipating Data Cleaning Issues When Working with HTML, JSON, and Spark Data. The implementation is an independently written practical utility.
