#!/usr/bin/env bash
set -e

# ============================================================
#  Hyprland  ->  bspwm
#
#  This script cleans out Wayland stuff (Hyprland),
#  installs a simple X11 + bspwm setup,
#  and enables LightDM.
#
#  You can run it even if half the files are missing.
#  It will just skip what isn't there.
# ============================================================

echo
echo "=============================================="
echo "  (╯°□°）╯︵  Hyprland → bspwm"
echo "=============================================="
echo

# ------------------------------------------------------------
# small helpers so logs don't look dead inside
# ------------------------------------------------------------
msg()   { echo "  -> $1"; }
ok()    { echo "     ✓ $1"; }
skip()  { echo "     · $1"; }
add()   { echo "     + $1"; }
rmv()   { echo "     - $1"; }

is_installed() {
  pacman -Q "$1" &>/dev/null
}

install_pkgs() {
  sudo pacman -S --needed --noconfirm "$@"
}

remove_pkgs() {
  for pkg in "$@"; do
    if is_installed "$pkg"; then
      rmv "Removing $pkg"
      sudo pacman -Rns --noconfirm "$pkg"
    else
      skip "$pkg not installed"
    fi
  done
}

safe_rm() {
  if [ -e "$1" ]; then
    rm -rf "$1"
    rmv "Removed $1"
  else
    skip "$1 not found"
  fi
}

# ------------------------------------------------------------
# sanity check
# ------------------------------------------------------------
msg "Checking system"
if ! command -v pacman >/dev/null; then
  echo "  x  pacman not found — this doesn't look like Arch"
  exit 1
fi
ok "Running on Arch"
echo

# ------------------------------------------------------------
# remove Hyprland / Wayland bits
# ------------------------------------------------------------
msg "Removing Hyprland / Wayland stuff (if any)"

remove_pkgs \
  hyprland \
  hyprpaper \
  hyprlock \
  hypridle \
  xdg-desktop-portal-hyprland \
  wayland \
  wayland-protocols

echo

# ------------------------------------------------------------
# clean leftover configs
# ------------------------------------------------------------
msg "Cleaning leftover config folders"

safe_rm "$HOME/.config/hypr"
safe_rm "$HOME/.config/wayland"
safe_rm "$HOME/.config/xdg-desktop-portal"

ok "Config cleanup done"
echo

# ------------------------------------------------------------
# install X11 + bspwm stack
# ------------------------------------------------------------
msg "Installing X11 + bspwm environment"

install_pkgs \
  xorg \
  xorg-xinit \
  bspwm \
  sxhkd \
  picom \
  feh \
  dmenu \
  alacritty \
  polybar \
  xdg-user-dirs \
  xdg-utils

ok "Packages installed"
echo

# ------------------------------------------------------------
# setup configs
# ------------------------------------------------------------
msg "Setting up bspwm / sxhkd configs"

mkdir -p "$HOME/.config/bspwm" "$HOME/.config/sxhkd"

if [ ! -f "$HOME/.config/bspwm/bspwmrc" ]; then
  cp /usr/share/doc/bspwm/examples/bspwmrc "$HOME/.config/bspwm/"
  chmod +x "$HOME/.config/bspwm/bspwmrc"
  add "Created bspwmrc"
else
  skip "bspwmrc already exists"
fi

if [ ! -f "$HOME/.config/sxhkd/sxhkdrc" ]; then
  cp /usr/share/doc/bspwm/examples/sxhkdrc "$HOME/.config/sxhkd/"
  add "Created sxhkdrc"
else
  skip "sxhkdrc already exists"
fi

echo

# ------------------------------------------------------------
# xinitrc
# ------------------------------------------------------------
msg "Checking ~/.xinitrc"

if [ ! -f "$HOME/.xinitrc" ]; then
  cat > "$HOME/.xinitrc" <<EOF
#!/bin/sh
exec bspwm
EOF
  chmod +x "$HOME/.xinitrc"
  add "Created .xinitrc"
else
  skip ".xinitrc already exists"
fi

echo

# ------------------------------------------------------------
# clean Wayland env vars
# ------------------------------------------------------------
msg "Cleaning Wayland env vars from shell configs"

FILES=(
  "$HOME/.profile"
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.config/fish/config.fish"
)

for file in "${FILES[@]}"; do
  [ -f "$file" ] || continue
  sed -i '/WAYLAND/d;/XDG_SESSION_TYPE/d;/GDK_BACKEND/d;/QT_QPA_PLATFORM/d' "$file"
  add "Cleaned $(basename "$file")"
done

echo

# ------------------------------------------------------------
# LightDM
# ------------------------------------------------------------
msg "Installing and enabling LightDM"

install_pkgs lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm.service

ok "LightDM enabled"
echo

# ------------------------------------------------------------
# done
# ------------------------------------------------------------
echo "=============================================="
echo "  (•‿•)  Done."
echo
echo "  What to do next:"
echo "    • Reboot"
echo "    • LightDM should come up"
echo "    • Choose bspwm and log in"
echo
echo "  If something was already deleted,"
echo "  the script just skipped it. No drama."
echo
echo "=============================================="
echo
