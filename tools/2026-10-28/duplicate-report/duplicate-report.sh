#!/usr/bin/env bash
# duplicate-report: Report identical files and potential redundant storage; never delete anything.
# Published 2026-10-28. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Report identical files and potential redundant storage; never delete anything.')
try:
    parser.add_argument("--root", required=True, type=Path, help="Directory to inspect; symlinks and hidden paths are skipped")
    args = parser.parse_args()
    import hashlib
    from collections import defaultdict
    if not args.root.is_dir():
        raise ValueError("root must be a directory")
    sizes = defaultdict(list)
    for path in sorted(args.root.rglob("*")):
        if path.is_symlink() or not path.is_file() or any(part.startswith(".") for part in path.relative_to(args.root).parts):
            continue
        sizes[path.stat().st_size].append(path)
    groups = []
    for size, paths in sorted(sizes.items()):
        if len(paths) < 2:
            continue
        hashes = defaultdict(list)
        for path in paths:
            digest = hashlib.sha256()
            with path.open("rb") as handle:
                for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                    digest.update(chunk)
            hashes[digest.hexdigest()].append(path.relative_to(args.root).as_posix())
        for digest, names in sorted(hashes.items()):
            if len(names) > 1:
                groups.append({"sha256": digest, "bytes_each": size, "paths": names, "redundant_bytes": size * (len(names) - 1)})
    result = {"duplicate_groups": groups, "potential_redundant_bytes": sum(group["redundant_bytes"] for group in groups)}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
