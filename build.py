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
    subprocess.run(args, cwd=ROOT, check=True)


def remove_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path, ignore_errors=True)


def find_built_executable(dist: Path, expected_name: str) -> Path | None:
    expected = dist / expected_name
    if expected.exists() and expected.is_file():
        return expected
    candidates = [p for p in dist.iterdir() if p.is_file() and p.name != "compilation-report.xml"]
    if platform.system() == "Windows":
        candidates = [p for p in candidates if p.suffix.lower() == ".exe"]
    else:
        candidates = [p for p in candidates if os.access(p, os.X_OK) or p.suffix == ""]
    return max(candidates, key=lambda p: p.stat().st_size, default=None)


def build_executable() -> bool:
    output_filename = executable_name()
    build_target = target_id()
    print(f"开始构建 {output_filename} ({build_target})")
    dist = ROOT / "dist"
    remove_dir(dist)
    for path in ROOT.glob("main.*"):
        if path.suffix in {".build", ".dist", ".onefile-build"} and path.exists():
            remove_dir(path)

    args = [
        sys.executable,
        "-m",
        "nuitka",
        "--standalone",
        "--onefile",
        "--assume-yes-for-downloads",
        "--show-progress",
        f"--jobs={os.cpu_count()}",
        "--enable-plugin=pyside6",
        "--include-qt-plugins=platforms,styles,qml,imageformats,iconengines",
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
        args.insert(-1, "--windows-console-mode=disable")

    try:
        run(args)
    except subprocess.CalledProcessError as exc:
        print(f"构建失败：{exc}")
        return False

    exe = find_built_executable(dist, output_filename)
    if exe is None:
        print("构建失败：未找到 Nuitka 生成的可执行文件。")
        if dist.exists():
            print("dist 内容：")
            for path in sorted(dist.rglob("*")):
                print(f" - {path.relative_to(dist)}")
        return False

    if exe.name != output_filename:
        target = dist / output_filename
        if target.exists():
            target.unlink()
        exe.rename(target)
        exe = target

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
        raise SystemExit(1)
    raise SystemExit(0 if build_executable() else 1)


if __name__ == "__main__":
    main()
