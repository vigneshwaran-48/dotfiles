#!/usr/bin/env bash
# Notification center for i3 (dunst history in rofi).
#   notifications.sh          open the center
#   notifications.sh watch    keep the bar counter file up to date (started by i3)
status_file="$HOME/.cache/i3-notifications"

update_status() {
	local n paused text
	n=$(dunstctl count history 2>/dev/null || echo 0)
	paused=$(dunstctl is-paused 2>/dev/null)
	if [[ "$paused" == "true" ]]; then text="󰂛 DND"
	elif (( n > 0 )); then text="󰂚 $n"
	else text="󰂜"
	fi
	if [[ "$(cat "$status_file" 2>/dev/null)" != "$text" ]]; then
		echo "$text" > "$status_file"
		killall -q -SIGUSR1 i3status
	fi
}

if [[ "$1" == "watch" ]]; then
	# single instance: a second copy exits immediately
	exec 9>"$status_file.lock"; flock -n 9 || exit 0
	while true; do update_status; sleep 2; done
fi

theme="$HOME/.config/rofi/applets/type-1/style-1.rasi"
dnd_label="󰂛  Do Not Disturb: off"
[[ "$(dunstctl is-paused)" == "true" ]] && dnd_label="󰂚  Do Not Disturb: on"
clear_label="󰎟  Clear all"

# id<TAB>display line, newest first
mapfile -t items < <(dunstctl history | jq -r '
	.data[0][] |
	"\(.id.data)\t\(.appname.data)  ·  \(.summary.data)\(if .body.data != "" then "  —  " + (.body.data | gsub("<[^>]*>"; "") | gsub("\n"; " ")) else "" end)"')

count=${#items[@]}
choice=$( {
	echo "$clear_label"
	echo "$dnd_label"
	for it in "${items[@]}"; do echo "${it#*$'\t'}"; done
} | rofi -dmenu -i -no-custom -format i \
	-p "󰂚" -mesg "$count notification(s) · Enter: show again" \
	-theme "$theme" \
	-theme-str 'window {width: 640px;} listview {lines: 10; columns: 1;}' )

[[ -z "$choice" ]] && exit 0
case "$choice" in
	0) dunstctl history-clear ;;
	1) dunstctl set-paused toggle ;;
	*) id="${items[$((choice-2))]%%$'\t'*}"; dunstctl history-pop "$id" ;;
esac
update_status
