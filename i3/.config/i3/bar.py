#!/usr/bin/env python3
"""i3bar status wrapper: runs i3status, adds a clickable notification bell.

Bell clicks: left = open notification center, middle = clear all, right = toggle Do Not Disturb.
Network clicks: left-click the wired/Wi-Fi item to copy its IP address.
The bell text comes from ~/.cache/i3-notifications (written by notifications.sh watch).
"""
import json, os, subprocess, sys, threading

HOME = os.path.expanduser("~")
STATUS_FILE = f"{HOME}/.cache/i3-notifications"
CENTER = f"{HOME}/.config/i3/notifications.sh"
ACTIONS = {
    1: [CENTER],
    2: ["dunstctl", "history-clear"],
    3: ["dunstctl", "set-paused", "toggle"],
}

i3status = subprocess.Popen(
    ["i3status", "-c", f"{HOME}/.config/i3status/config"],
    stdout=subprocess.PIPE, text=True, bufsize=1)


def bell():
    try:
        text = open(STATUS_FILE).read().strip()
    except OSError:
        text = "󰂜"
    return {"name": "notifications", "full_text": text, "color": "#ABB2BF"}


def copy_ip(iface):
    """Copy the interface's IPv4 address to the clipboard and confirm with a notification."""
    out = subprocess.run(["ip", "-4", "-o", "addr", "show", iface],
                         capture_output=True, text=True).stdout.split()
    ip = out[out.index("inet") + 1].split("/")[0] if "inet" in out else None
    if not ip:
        subprocess.run(["dunstify", "-a", "Network", "-u", "low", f"{iface}: no IP address"])
        return
    subprocess.run(["xclip", "-selection", "clipboard"], input=ip, text=True)
    subprocess.run(["dunstify", "-a", "Network", "-u", "low", "--replace=698",
                    "IP copied", f"{ip}  ({iface})"])


def handle_clicks():
    for line in sys.stdin:
        line = line.strip().lstrip(",")
        if not line or line == "[":
            continue
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if event.get("name") in ("ethernet", "wireless") and event.get("button") == 1:
            threading.Thread(target=copy_ip, args=(event.get("instance"),), daemon=True).start()
            continue
        cmd = ACTIONS.get(event.get("button")) if event.get("name") == "notifications" else None
        if cmd:
            subprocess.Popen(cmd, start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if cmd[0] == "dunstctl":   # refresh the bell right away
                subprocess.run(["killall", "-q", "-SIGUSR1", "i3status"])


def emit(text):
    try:
        sys.stdout.write(text + "\n")
        sys.stdout.flush()
    except BrokenPipeError:          # i3bar went away (reload/exit)
        i3status.terminate()
        os._exit(0)


threading.Thread(target=handle_clicks, daemon=True).start()

header = json.loads(i3status.stdout.readline())
header["click_events"] = True
emit(json.dumps(header))
emit(i3status.stdout.readline().strip())          # opening "["

for line in i3status.stdout:
    prefix, line = ("," , line[1:]) if line.startswith(",") else ("", line)
    try:
        blocks = json.loads(line)
    except ValueError:
        continue
    # put the bell just before the clock (last block)
    blocks.insert(max(len(blocks) - 1, 0), bell())
    emit(prefix + json.dumps(blocks, ensure_ascii=False))
