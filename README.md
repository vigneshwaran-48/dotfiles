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
