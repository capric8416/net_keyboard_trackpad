"""Compile and test the real XTEST backend in an isolated Xvfb display."""
from __future__ import annotations

import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile

from project_tools import ROOT


def main() -> None:
    flutter = shutil.which("flutter")
    if flutter is None:
        raise SystemExit("flutter must be on PATH")
    sdk = Path(flutter).resolve().parent.parent
    engine = sdk / "bin/cache/artifacts/engine/linux-x64"
    if not engine.is_dir():
        raise SystemExit("Run flutter precache --linux first (test requires x64 Linux).")
    source = (ROOT / "packages/remote_input_core/lib/src/semantic_key.dart").read_text()
    names = re.findall(r"^  (\w+),$", source.split("enum SemanticKey {", 1)[1].split("}", 1)[0], re.M)
    flags = shlex.split(subprocess.check_output(
        ["pkg-config", "--cflags", "--libs", "gtk+-3.0", "x11", "xtst", "gio-unix-2.0"], text=True))
    with tempfile.TemporaryDirectory(prefix="linux-input-test-") as directory:
        binary = str(Path(directory) / "input_test")
        subprocess.run([
            "clang++", "-std=c++14", "-Wall", "-Werror",
            str(ROOT / "apps/desktop_app/linux/runner/tests/input_test.cc"),
            str(ROOT / "apps/desktop_app/linux/runner/wayland_input.cc"),
            f"-I{engine}", f"-L{engine}", f"-Wl,-rpath,{engine}",
            "-lflutter_linux_gtk", *flags, "-o", binary,
        ], check=True)
        portal_binary = str(Path(directory) / "wayland_portal_test")
        subprocess.run([
            "clang++", "-std=c++14", "-Wall", "-Werror",
            str(ROOT / "apps/desktop_app/linux/runner/tests/wayland_portal_test.cc"),
            f"-I{engine}", f"-L{engine}", f"-Wl,-rpath,{engine}",
            "-lflutter_linux_gtk", *flags, "-o", portal_binary,
        ], check=True)
        subprocess.run(["dbus-run-session", "--", portal_binary],
                       env=dict(os.environ, NET_KEYBOARD_PORTAL_TEST="1"),
                       check=True, timeout=45)
        # Let Xvfb allocate a free display; no interaction with the user's desktop.
        with tempfile.TemporaryFile() as display_file:
            server = subprocess.Popen([
                "Xvfb", "-displayfd", str(display_file.fileno()),
                "-screen", "0", "800x600x24", "-nolisten", "tcp",
            ], pass_fds=(display_file.fileno(),), stderr=subprocess.DEVNULL)
            try:
                import time
                display = ""
                for _ in range(100):
                    display_file.seek(0)
                    display = display_file.read().decode().strip()
                    if display or server.poll() is not None:
                        break
                    time.sleep(0.05)
                if not display:
                    raise SystemExit("Xvfb failed to start")
                env = dict(os.environ, DISPLAY=f":{display}", GDK_BACKEND="x11", XDG_SESSION_TYPE="x11")
                subprocess.run([binary, *names], env=env, check=True, timeout=30)
            finally:
                server.terminate()
                server.wait(timeout=5)


if __name__ == "__main__":
    main()
