#!/usr/bin/env sh
# Draw the wallpaper on every screen (re-run by monitors.sh after a monitor is plugged/unplugged).
# Uses ~/Pictures/Wallpapers/wallpaper1.jpg, else GNOME's dark-mode wallpaper, else a solid colour.
wp="$HOME/Pictures/Wallpapers/wallpaper1.jpg"
[ -f "$wp" ] || wp=$(gsettings get org.gnome.desktop.background picture-uri-dark | sed "s|^.file://||; s|.$||")
if command -v feh >/dev/null && [ -f "$wp" ]; then
	feh --no-fehbg --bg-fill "$wp"
else
	xsetroot -solid "#1E2127"
fi
