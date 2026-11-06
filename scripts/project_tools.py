"""Shared process helpers for repository tooling."""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path
from typing import Iterable


ROOT = Path(__file__).resolve().parents[1]


def executable(name: str) -> str:
    """Return an executable on PATH or stop with an actionable message."""
    value = shutil.which(name)
    if value is None:
        raise SystemExit(f"Required executable `{name}` was not found on PATH.")
    return value


def run(
    command: Iterable[str | Path],
    *,
    cwd: Path = ROOT,
    env: dict[str, str] | None = None,
) -> None:
    rendered = [str(part) for part in command]
    print(f"+ {' '.join(rendered)}", flush=True)
    subprocess.run(rendered, cwd=cwd, env=env, check=True)


def pub_cache_bin() -> Path | None:
    """Find the Dart global executable directory without assuming one OS."""
    configured = os.environ.get("PUB_CACHE")
    candidates: list[Path] = []
    if configured:
        candidates.append(Path(configured) / "bin")
    candidates.append(Path.home() / ".pub-cache" / "bin")
    local_app_data = os.environ.get("LOCALAPPDATA")
    if local_app_data:
        candidates.append(Path(local_app_data) / "Pub" / "Cache" / "bin")
    return next((candidate for candidate in candidates if candidate.is_dir()), None)


def environment_with_pub_cache_bin() -> dict[str, str]:
    result = os.environ.copy()
    bin_dir = pub_cache_bin()
    if bin_dir is not None:
        result["PATH"] = f"{bin_dir}{os.pathsep}{result.get('PATH', '')}"
    return result

