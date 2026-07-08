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


def log_event(entry: dict) -> None:
    log_path = Path(os.environ.get("CODEX_NOTIFY_LOG", "~/.codex/notify.log")).expanduser()
    try:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        with log_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False, sort_keys=True) + "\n")
    except OSError:
        pass


def log_notification(notification: dict) -> None:
    log_event(
        {
            "type": notification.get("type"),
            "thread-id": notification.get("thread-id"),
            "turn-id": notification.get("turn-id"),
            "cwd": notification.get("cwd") or notification.get("current-dir"),
            "client": notification.get("client"),
        }
    )


def apple_script_string(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
    return f'"{escaped}"'


def notify_via_osascript(title: str, message: str, subtitle: str) -> subprocess.CompletedProcess[str]:
    body = message if not subtitle else f"{message} ({subtitle})"
    script = f"display notification {apple_script_string(body)} with title {apple_script_string(title)}"
    return subprocess.run(
        ["osascript", "-e", script],
        check=False,
        capture_output=True,
        text=True,
    )


def notify_via_terminal_notifier(
    notifier: str, title: str, message: str, thread_id: str, subtitle: str, activate: str
) -> subprocess.CompletedProcess[str]:
    command = [
        notifier,
        "-title",
        title,
        "-message",
        message,
        "-group",
        "codex-" + thread_id,
    ]

    if subtitle:
        command.extend(["-subtitle", subtitle])

    if activate:
        command.extend(["-activate", activate])

    return subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
    )


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
        notification_result = notify_via_osascript(
            os.environ.get("CODEX_NOTIFY_TITLE", "Codex"),
            message,
            str(notification.get("cwd") or notification.get("current-dir") or ""),
        )
        if notification_result.returncode != 0:
            log_event(
                {
                    "type": notification.get("type"),
                    "thread-id": notification.get("thread-id"),
                    "turn-id": notification.get("turn-id"),
                    "cwd": notification.get("cwd") or notification.get("current-dir"),
                    "client": notification.get("client"),
                    "delivery": "osascript",
                    "returncode": notification_result.returncode,
                    "stderr": notification_result.stderr.strip() if notification_result.stderr else "",
                }
            )
        return 0

    thread_id = str(notification.get("thread-id", ""))
    cwd = notification.get("cwd") or notification.get("current-dir") or ""
    title = os.environ.get("CODEX_NOTIFY_TITLE", "Codex")
    activate = os.environ.get("CODEX_NOTIFY_ACTIVATE_BUNDLE", "com.github.wez.wezterm")
    notification_result = notify_via_terminal_notifier(
        notifier,
        title,
        message,
        thread_id,
        str(cwd),
        activate,
    )

    if notification_result.returncode != 0:
        log_event(
            {
                "type": notification.get("type"),
                "thread-id": notification.get("thread-id"),
                "turn-id": notification.get("turn-id"),
                "cwd": notification.get("cwd") or notification.get("current-dir"),
                "client": notification.get("client"),
                "delivery": "terminal-notifier",
                "returncode": notification_result.returncode,
                "stderr": notification_result.stderr.strip() if notification_result.stderr else "",
            }
        )
        fallback_result = notify_via_osascript(title, message, str(cwd))
        if fallback_result.returncode != 0:
            log_event(
                {
                    "type": notification.get("type"),
                    "thread-id": notification.get("thread-id"),
                    "turn-id": notification.get("turn-id"),
                    "cwd": notification.get("cwd") or notification.get("current-dir"),
                    "client": notification.get("client"),
                    "delivery": "osascript",
                    "returncode": fallback_result.returncode,
                    "stderr": fallback_result.stderr.strip() if fallback_result.stderr else "",
                }
            )
    return 0


if __name__ == "__main__":
    sys.exit(main())
