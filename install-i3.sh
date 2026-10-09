#!/usr/bin/env bash
# install-i3.sh — set up the i3 desktop from this dotfiles repo (Ubuntu 24.04+).
#
# What it does:
#   1. Installs the packages the configs rely on (apt).
#   2. Downloads the rofi theme images (third-party, not stored in this repo).
#   3. Backs up any existing config files that would conflict, then links the
#      configs into place with GNU Stow.
#   4. Checks for machine-specific things you may need to adjust.
#   5. Optionally fixes /etc/shadow permissions so the lock screen can check passwords.
#
# Safe to re-run. Nothing outside your home directory is changed without asking,
# apart from installing packages.
#
# Usage:  ./install-i3.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(i3 i3status dunst rofi xdg-portal xscreensaver gtk desktop-entries)
STAMP="$(date +%Y%m%d-%H%M%S)"

bold() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    \033[33m! %s\033[0m\n' "$*"; }
ask()  { local reply; read -rp "    $1 [y/N] " reply; [[ "$reply" =~ ^[Yy]$ ]]; }

command -v apt-get >/dev/null || { echo "This script expects an apt-based system (Ubuntu/Debian)."; exit 1; }

# ── 1. Packages ──────────────────────────────────────────────────────────────
bold "Installing packages (needs sudo)"
APT_PACKAGES=(
	i3                       # i3-wm, i3status, i3lock, dunst, dmenu, dex
	stow git python3 jq
	rofi                     # launcher, power menu, notification center
	maim xclip xdotool       # screenshots + clipboard
	feh                      # wallpaper
	libnotify-bin            # notify-send
	x11-xserver-utils xinput # xrandr, xrdb, xsetroot; touchpad settings
	brightnessctl wireplumber
	network-manager-gnome    # nm-applet (Wi-Fi tray icon)
	gnome-settings-daemon    # gsd-xsettings: GNOME theme/dark mode for apps
	xdg-desktop-portal-gtk   # dark mode signal for libadwaita apps
	gnome-tweaks eog         # theme GUI, image viewer for screenshots
)
sudo apt-get update
sudo apt-get install -y "${APT_PACKAGES[@]}"
# Lock screen only — skip the hundreds of screensaver animations
sudo apt-get install -y --no-install-recommends xscreensaver

if ask "Install optional extra picom (transparency, tear-free)?"; then
	sudo apt-get install -y picom
fi

# ── 2. rofi images (third-party, from adi1090x/rofi) ─────────────────────────
bold "rofi theme images"
IMG_DIR="$DOTFILES/rofi/.config/rofi/images"
if [[ -f "$IMG_DIR/d.png" ]]; then
	info "already present"
else
	tmp="$(mktemp -d)"
	git clone --depth 1 https://github.com/adi1090x/rofi "$tmp/rofi"
	mkdir -p "$IMG_DIR"
	cp -n "$tmp/rofi/files/images/"* "$IMG_DIR/"
	rm -rf "$tmp"
	info "downloaded to $IMG_DIR"
fi

# ── 3. Link configs with stow ────────────────────────────────────────────────
bold "Linking configs into \$HOME"
cd "$DOTFILES"
for pkg in "${PACKAGES[@]}"; do
	# Find files stow would refuse to overwrite, and move them aside first
	while read -r target; do
		[[ -z "$target" ]] && continue
		src="$HOME/$target"
		if [[ -e "$src" && ! -L "$src" ]]; then
			mv "$src" "$src.pre-dotfiles-$STAMP"
			info "backed up ~/$target -> ~/$target.pre-dotfiles-$STAMP"
		fi
	done < <(stow -n -v -t "$HOME" "$pkg" 2>&1 | sed -n 's/.*existing target \(is neither a link nor a directory\|is not owned by stow\): //p; s/.*over existing target \(.*\) since.*/\1/p')
	stow -t "$HOME" "$pkg"
	info "linked $pkg"
done

# ── 4. Machine-specific checks ───────────────────────────────────────────────
bold "Checking machine-specific settings"

fc-list | grep -qi "JetBrainsMono Nerd Font" \
	|| warn "JetBrainsMono Nerd Font not found (bar/rofi/dunst icons). Get it from https://www.nerdfonts.com"
command -v alacritty >/dev/null \
	|| warn "alacritty not found (Win+Enter). Install it, or change the terminal in i3/.config/i3/config"

for theme in Mojave-Dark; do
	[[ -d "$HOME/.themes/$theme" || -d /usr/share/themes/$theme ]] \
		|| warn "GTK theme '$theme' not found — set another one in GNOME Tweaks (gtk/.config/gtk-3.0/settings.ini)"
done
for icons in WhiteSur-dark Polarnight-cursors; do
	[[ -d "$HOME/.icons/$icons" || -d "$HOME/.local/share/icons/$icons" || -d /usr/share/icons/$icons ]] \
		|| warn "Icon/cursor theme '$icons' not found — pick another one in GNOME Tweaks"
done

I3STATUS="$DOTFILES/i3status/.config/i3status/config"
wifi="$(basename "$(dirname "$(ls -d /sys/class/net/*/wireless 2>/dev/null | head -1)")" 2>/dev/null || true)"
eth="$(ls /sys/class/net | grep -E '^(en|eth)' | head -1 || true)"
cfg_wifi="$(sed -n 's/^order += "wireless \(.*\)"/\1/p' "$I3STATUS")"
cfg_eth="$(sed -n 's/^order += "ethernet \(.*\)"/\1/p' "$I3STATUS")"
if [[ -n "$wifi" && "$wifi" != "$cfg_wifi" ]] || [[ -n "$eth" && "$eth" != "$cfg_eth" ]]; then
	warn "Network interfaces differ from the bar config (config: ${cfg_wifi:-none}/${cfg_eth:-none}, this machine: ${wifi:-none}/${eth:-none})."
	if ask "Update the bar config to use ${wifi:-$cfg_wifi} / ${eth:-$cfg_eth}?"; then
		[[ -n "$wifi" ]] && sed -i "s/\b$cfg_wifi\b/$wifi/g" "$I3STATUS"
		[[ -n "$eth"  ]] && sed -i "s/\b$cfg_eth\b/$eth/g" "$I3STATUS"
		info "updated $I3STATUS"
	fi
fi


# ── 5. Lock screen password check ────────────────────────────────────────────
bold "Lock screen"
# X11 lock screens run as your user and verify passwords through unix_chkpwd,
# which needs group 'shadow' read access to /etc/shadow (Ubuntu's default:
# root:shadow 640). Some hardened setups make it root-only, and then every
# lock screen rejects the correct password.
shadow_perm="$(stat -c '%U:%G %a' /etc/shadow)"
if [[ "$shadow_perm" == "root:shadow 640" ]]; then
	info "/etc/shadow has Ubuntu's default permissions — lock screen will work"
else
	warn "/etc/shadow is '$shadow_perm' (Ubuntu default: 'root:shadow 640')."
	warn "With this, xscreensaver/i3lock cannot verify your password and you would be locked out."
	warn "On a managed (work) machine, check with your IT team before changing it."
	if ask "Restore Ubuntu's default permissions on /etc/shadow?"; then
		sudo chown root:shadow /etc/shadow && sudo chmod 640 /etc/shadow
		info "done"
	else
		warn "Skipped. Until fixed, lock by logging out (Win+X -> Logout) instead of Win+Escape."
	fi
fi

bold "Done"
info "Log out, pick 'i3' on the login screen (gear icon), and log in."
info "Already in i3? Press Win+Shift+R to reload."
info "Keys: Win+D apps · Win+N notifications · Win+X power menu · Win+Escape lock · Print screenshot"
