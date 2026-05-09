#!/usr/bin/env python3
import json
import os
import platform
import shutil
import subprocess
import sys


def main() -> int:
    if len(sys.argv) != 2:
        return 1

    try:
        notification = json.loads(sys.argv[1])
    except json.JSONDecodeError:
        return 1

    if notification.get("type") != "agent-turn-complete":
        return 0

    if platform.system() != "Darwin":
        return 0

    notifier = shutil.which("terminal-notifier")
    if notifier is None:
        return 0

    thread_id = str(notification.get("thread-id", ""))
    cwd = notification.get("cwd") or notification.get("current-dir") or ""
    title = os.environ.get("CODEX_NOTIFY_TITLE", "Codex")
    message = os.environ.get("CODEX_NOTIFY_MESSAGE", "Codexの処理が完了しました")

    command = [
        notifier,
        "-title",
        title,
        "-message",
        message,
        "-group",
        "codex-" + thread_id,
    ]

    if cwd:
        command.extend(["-subtitle", str(cwd)])

    activate = os.environ.get("CODEX_NOTIFY_ACTIVATE_BUNDLE", "com.github.wez.wezterm")
    if activate:
        command.extend(["-activate", activate])

    subprocess.run(command, check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
