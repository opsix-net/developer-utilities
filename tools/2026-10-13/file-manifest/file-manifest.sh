#!/usr/bin/env bash
# file-manifest: Produce a deterministic SHA-256 inventory without modifying any files.
# Published 2026-10-13. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Produce a deterministic SHA-256 inventory without modifying any files.')
try:
    parser.add_argument("--root", required=True, type=Path, help="Directory to inventory; symlinks and hidden paths are skipped")
    args = parser.parse_args()
    import hashlib
    if not args.root.is_dir():
        raise ValueError("root must be a directory")
    files = []
    for path in sorted(args.root.rglob("*")):
        relative = path.relative_to(args.root)
        if path.is_symlink() or not path.is_file() or any(part.startswith(".") for part in relative.parts):
            continue
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        files.append({"path": relative.as_posix(), "bytes": path.stat().st_size, "sha256": digest.hexdigest()})
    result = {"files": files, "file_count": len(files), "total_bytes": sum(file["bytes"] for file in files)}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
