#!/usr/bin/env bash
# Monitor layout for i3: laptop screen is primary on the left, external monitors to its right.
# Unplugged monitors are switched off, so i3 moves their workspaces onto the remaining screen.
#
#   monitors.sh         apply the layout once
#   monitors.sh watch   re-apply whenever a monitor is plugged in or unplugged (started by i3)

apply() {
	local query laptop prev="" args=()
	query="$(xrandr --query)"
	laptop="$(awk '/^eDP[^ ]* connected/{print $1; exit}' <<<"$query")"

	# laptop screen first, then the others in xrandr order
	while read -r name state; do
		if [[ "$state" == "connected" ]]; then
			if [[ "$name" == "$laptop" ]]; then
				args+=(--output "$name" --auto --primary)
			else
				args+=(--output "$name" --auto ${prev:+--right-of "$prev"})
			fi
			prev="$name"
		else
			args+=(--output "$name" --off)
		fi
	done < <(awk '/ (dis)?connected/{print $1, $2}' <<<"$query" \
		| awk -v l="$laptop" '$1==l{print; next} {rest=rest $0 "\n"} END{printf "%s", rest}')

	xrandr "${args[@]}"
}

if [[ "$1" == "watch" ]]; then
	# single instance: a second copy exits immediately
	exec 9>"$HOME/.cache/i3-monitors.lock"; flock -n 9 || exit 0
	apply
	# Kernel connector status changes instantly on plug/unplug and is cheap to read
	# (unlike `xrandr --query`, which re-probes every output).
	last="$(cat /sys/class/drm/*/status 2>/dev/null)"
	while sleep 2; do
		now="$(cat /sys/class/drm/*/status 2>/dev/null)"
		if [[ "$now" != "$last" ]]; then
			last="$now"
			sleep 1   # let the monitor finish waking up / disconnecting
			apply
		fi
	done
fi

apply
