# Hyprland to bspwm

A simple, human-friendly script to switch from Hyprland (Wayland) to bspwm (X11) on Arch Linux.

## Usage

```bash
./hyprland-to-bspwm.sh [options]
```

### Options

| Option | Description |
| :--- | :--- |
| `--no-lightdm` | Skip installing/enabling LightDM. Useful if you want to use a different display manager or start X manually. |
| `--keep-wayland` | Skip removing Hyprland and Wayland packages/configs. Useful if you want to dual-boot Wayland and X11. |

## Notes

- **NVIDIA users must reboot after this script.**
- Secure Boot must be disabled for proprietary NVIDIA drivers.
- If using Optimus laptops, the script will attempt to install `optimus-manager`.
