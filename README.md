## dotfiles

## i3 desktop

i3 (X11) with a One Dark theme, rofi launcher/power menu, dunst notification
center, xscreensaver lock screen, maim screenshots and GNOME dark mode for apps.

```sh
./install-i3.sh
```

Installs the packages, links `i3 i3status dunst rofi xdg-portal xscreensaver gtk
desktop-entries` with GNU Stow (backing up anything in the way), and checks for
machine-specific settings (network interfaces, fonts, themes).

### Packages

Installed by `install-i3.sh` (apt, Ubuntu 24.04):

| Package | Used for |
|---|---|
| `i3` | Window manager; pulls in `i3-wm`, `i3status`, `i3lock`, `dunst`, `dmenu`, `dex` |
| `xscreensaver` (`--no-install-recommends`) | Lock screen (blank + password dialog, no animations) |
| `rofi` | App launcher, power menu, notification center, screenshot menu |
| `dunst` | Notifications (comes with `i3`) |
| `maim`, `xclip`, `xdotool` | Screenshots, copy to clipboard, active window |
| `feh` | Wallpaper |
| `libnotify-bin` | `notify-send` |
| `x11-xserver-utils`, `xinput` | `xrandr` (monitors), `xrdb`, `xsetroot`; touchpad settings |
| `brightnessctl`, `wireplumber` | Brightness and volume keys (`wpctl`) |
| `network-manager-gnome` | `nm-applet` Wi-Fi tray icon |
| `gnome-settings-daemon` | `gsd-xsettings`: GNOME theme, icons, dark mode for apps |
| `xdg-desktop-portal-gtk` | Dark-mode signal for newer (libadwaita) apps |
| `gnome-tweaks`, `eog` | Theme settings GUI; image viewer for screenshots |
| `stow`, `git`, `python3`, `jq` | Linking dotfiles, bar wrapper (`bar.py`), notification history parsing |
| `picom` *(optional, asked)* | Compositor: transparency, tear-free, tinted screenshot selection |

Not installed by the script — set these up yourself:

- **JetBrainsMono Nerd Font** — icons in the bar, rofi, dunst ([nerdfonts.com](https://www.nerdfonts.com))
- **Alacritty** — terminal on `Win+Enter`
- **Mojave-Dark** GTK theme, **WhiteSur-dark** icons, **Polarnight** cursors (or pick others in GNOME Tweaks)
- **Wallpaper** at `~/Pictures/Wallpapers/wallpaper1.jpg` (falls back to the GNOME wallpaper)

| Key | Action |
|---|---|
| `Win+D` / `Alt+Space` | App launcher (rofi) |
| `Win+X` | Power menu |
| `Win+N` / click bell | Notification center |
| `Win+Escape` | Lock screen |
| `Print`, `Win+Shift+S` | Screenshot menu, area screenshot |
| click network item | Copy IP address |

rofi theme: [adi1090x/rofi](https://github.com/adi1090x/rofi) (GPL-3.0).
Its images are not stored here; the install script downloads them.
