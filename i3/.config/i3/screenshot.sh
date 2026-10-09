#!/usr/bin/env bash
# Quick screenshots for i3: ./screenshot.sh full|area|window
# Saves to ~/Pictures/Screenshots, copies to clipboard, shows a notification.
dir="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$dir"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$1" in
	# Tinted highlight needs a compositor (picom); otherwise just draw an outline
	area)   if pgrep -x picom >/dev/null; then hl="-l -c 0.38,0.69,0.94,0.25"; else hl="-c 0.38,0.69,0.94,1"; fi
	        maim -u -f png -s -b 2 $hl "$file" ;;
	window) maim -u -f png -i "$(xdotool getactivewindow)" "$file" ;;
	*)      maim -u -f png "$file" ;;
esac || exit 0   # selection cancelled with Esc / right-click

xclip -selection clipboard -t image/png < "$file"
dunstify -a Screenshot -u low --replace=699 -i "$file" "Screenshot saved" "Copied to clipboard · $(basename "$file")"
