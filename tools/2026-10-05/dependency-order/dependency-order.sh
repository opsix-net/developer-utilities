#!/usr/bin/env bash
# dependency-order: Find a deterministic topological order and flag cyclic dependency graphs.
# Published 2026-10-05. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Find a deterministic topological order and flag cyclic dependency graphs.')
try:
    parser.add_argument("--file", required=True, type=Path, help="JSON object mapping each task to a list of dependencies")
    args = parser.parse_args()
    import heapq
    graph = json.loads(args.file.read_text(encoding="utf-8"))
    if not isinstance(graph, dict) or any(not isinstance(node, str) or not isinstance(deps, list) or any(not isinstance(dep, str) for dep in deps) for node, deps in graph.items()):
        raise ValueError("expected a JSON object mapping task names to dependency lists")
    nodes = set(graph) | {dep for deps in graph.values() for dep in deps}
    requirements = {node: set(graph.get(node, [])) for node in nodes}
    dependents = {node: set() for node in nodes}
    for node, deps in requirements.items():
        for dep in deps:
            dependents[dep].add(node)
    queue = sorted(node for node in nodes if not requirements[node])
    heapq.heapify(queue)
    order = []
    while queue:
        node = heapq.heappop(queue)
        order.append(node)
        for target in sorted(dependents[node]):
            requirements[target].remove(node)
            if not requirements[target]:
                heapq.heappush(queue, target)
    blocked = sorted(nodes - set(order))
    result = {"ok": not blocked, "topological_order": order, "blocked_nodes": blocked, "nodes": len(nodes)}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
