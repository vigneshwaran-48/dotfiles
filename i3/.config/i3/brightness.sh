#!/usr/bin/env bash
# Screen brightness for i3: brightness.sh up|down [step%]
# Sets brightness through systemd-logind (like GNOME does), so it works without root
# or membership in the 'video' group. brightnessctl is only used to read the values.
step="${2:-5}"
IFS=, read -r dev _ cur _ max < <(brightnessctl -m -c backlight info)

case "$1" in
	up)   new=$(( cur + max * step / 100 )) ;;
	down) new=$(( cur - max * step / 100 )) ;;
	*)    echo "usage: $0 up|down [step%]" >&2; exit 1 ;;
esac
min=$(( max / 100 ))                       # never go fully black
(( new > max )) && new=$max
(( new < min )) && new=$min

busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto \
	org.freedesktop.login1.Session SetBrightness ssu backlight "$dev" "$new"

pct=$(( new * 100 / max ))
dunstify -a Brightness -u low --replace=697 -h "int:value:$pct" "󰃠  Brightness $pct%"
