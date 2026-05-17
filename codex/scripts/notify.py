#!/usr/bin/env python3
import json
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


WAITING_TYPE_KEYWORDS = (
    "approval",
    "input",
    "interrupt",
    "request",
    "waiting",
)


def message_for(notification: dict) -> str | None:
    notification_type = str(notification.get("type", ""))

    if notification_type == "agent-turn-complete":
        return os.environ.get("CODEX_NOTIFY_MESSAGE", "Codexの処理が完了しました")

    if any(keyword in notification_type for keyword in WAITING_TYPE_KEYWORDS):
        return os.environ.get("CODEX_NOTIFY_WAITING_MESSAGE", "Codexが入力待ちです")

    return None


def log_notification(notification: dict) -> None:
    log_path = Path(os.environ.get("CODEX_NOTIFY_LOG", "~/.codex/notify.log")).expanduser()
    log_entry = {
        "type": notification.get("type"),
        "thread-id": notification.get("thread-id"),
        "turn-id": notification.get("turn-id"),
        "cwd": notification.get("cwd") or notification.get("current-dir"),
        "client": notification.get("client"),
    }
    try:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        with log_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry, ensure_ascii=False, sort_keys=True) + "\n")
    except OSError:
        pass


def main() -> int:
    if len(sys.argv) != 2:
        return 1

    try:
        notification = json.loads(sys.argv[1])
    except json.JSONDecodeError:
        return 1

    log_notification(notification)

    message = message_for(notification)
    if message is None:
        return 0

    if platform.system() != "Darwin":
        return 0

    notifier = shutil.which("terminal-notifier")
    if notifier is None:
        return 0

    thread_id = str(notification.get("thread-id", ""))
    cwd = notification.get("cwd") or notification.get("current-dir") or ""
    title = os.environ.get("CODEX_NOTIFY_TITLE", "Codex")

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
