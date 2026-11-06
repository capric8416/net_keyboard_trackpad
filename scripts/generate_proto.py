"""Generate Dart protobuf and gRPC sources on every supported host OS."""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


def require_executable(name: str) -> str:
    executable = shutil.which(name)
    if executable is None:
        raise SystemExit(
            f"{name} was not found on PATH. "
            "Install protoc and run `dart pub global activate protoc_plugin` first."
        )
    return executable


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    protocol = root / "packages" / "remote_input_protocol"
    proto_dir = protocol / "proto"
    output_dir = protocol / "lib" / "src" / "generated"
    output_dir.mkdir(parents=True, exist_ok=True)

    protoc = require_executable("protoc")
    require_executable("protoc-gen-dart")
    subprocess.run(
        [
            protoc,
            f"--proto_path={proto_dir}",
            f"--dart_out=grpc:{output_dir}",
            str(proto_dir / "remote_input.proto"),
        ],
        check=True,
        cwd=root,
    )


if __name__ == "__main__":
    main()

