"""Nuitka 打包脚本，适配本地和 GitHub Actions。"""

from __future__ import annotations

import os
import platform
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path


APP_NAME = "BreatheLens"
ROOT = Path(__file__).resolve().parent


def target_id() -> str:
    value = os.environ.get("BUILD_TARGET")
    if value:
        return value
    system = platform.system().lower()
    machine = platform.machine().lower().replace("amd64", "x64").replace("x86_64", "x64")
    machine = machine.replace("aarch64", "arm64")
    return f"{system}-{machine}"


def executable_name() -> str:
    return f"{APP_NAME}.exe" if platform.system() == "Windows" else APP_NAME


def run(args: list[str]) -> None:
    print(" ".join(args))
    subprocess.run(args, cwd=ROOT, check=True, text=True, encoding="utf-8")


def build_executable() -> bool:
    output_filename = executable_name()
    build_target = target_id()
    print(f"开始构建 {output_filename} ({build_target})")
    dist = ROOT / "dist"
    if dist.exists():
        shutil.rmtree(dist)
    for path in ROOT.glob("main.*"):
        if path.suffix in {".build", ".dist", ".onefile-build"} and path.exists():
            shutil.rmtree(path)

    args = [
        sys.executable,
        "-m",
        "nuitka",
        "--standalone",
        "--onefile",
        "--onefile-tempdir-spec={PROGRAM_DIR}/temp",
        "--assume-yes-for-downloads",
        "--show-progress",
        f"--jobs={os.cpu_count()}",
        "--enable-plugin=pyside6",
        "--include-qt-plugins=platforms,qml",
        "--include-module=PySide6.QtCore",
        "--include-module=PySide6.QtGui",
        "--include-module=PySide6.QtQml",
        "--include-module=PySide6.QtQuick",
        "--include-module=PySide6.QtQuickControls2",
        "--include-package=openpyxl",
        "--nofollow-import-to=PySide6.QtWebEngine",
        "--nofollow-import-to=PySide6.QtMultimedia",
        "--nofollow-import-to=PySide6.QtSql",
        "--nofollow-import-to=PySide6.QtTest",
        "--include-data-dir=ui=ui",
        f"--output-filename={output_filename}",
        "--output-dir=dist",
        "--report=compilation-report.xml",
        "main.py",
    ]
    if platform.system() == "Windows":
        args.insert(-5, "--windows-console-mode=disable")

    try:
        run(args)
    except subprocess.CalledProcessError as exc:
        print(f"构建失败：{exc}")
        return False

    exe = dist / output_filename
    if exe.exists():
        size_mb = exe.stat().st_size / 1024 / 1024
        print(f"构建完成：{exe} ({size_mb:.1f} MB)")
        zip_path = dist / f"{APP_NAME}-{build_target}.zip"
        with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
            zf.write(exe, exe.name)
            readme = ROOT / "README.md"
            license_file = ROOT / "LICENSE"
            if readme.exists():
                zf.write(readme, readme.name)
            if license_file.exists():
                zf.write(license_file, license_file.name)
        print(f"压缩包：{zip_path}")
    return True


def main() -> None:
    if not (ROOT / ".venv").exists():
        print("未发现 .venv，请先运行：uv venv .venv && uv sync")
        return
    build_executable()


if __name__ == "__main__":
    main()
