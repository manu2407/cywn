#!/usr/bin/env bash

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
