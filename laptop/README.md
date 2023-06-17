# Laptop setup

ArchLinux with GNOME, full disk encryption and systemd-boot/UKI boot.

## Dotfiles

```shell
mv ~/.config/environment.d ~/.config/environment.d.bak
ln -s "$(pwd)/laptop/resources/dotfiles/environment.d" ~/.config/environment.d

mkdir -p ~/.config/fish
mv ~/.config/fish/functions ~/.config/fish/functions.bak
ln -s "$(pwd)/laptop/resources/dotfiles/fish/functions" ~/.config/fish/functions

mkdir -p ~/.config/pacdef
ln -si "$(pwd)/laptop/resources/dotfiles/pacdef/pacdef.yaml" ~/.config/pacdef/pacdef.yaml

mkdir -p ~/.config/gtk-3.0
ln -si "$(pwd)/laptop/resources/dotfiles/gtk-3.0/gtk.css" ~/.config/gtk-3.0/gtk.css

ln -si "$(pwd)/laptop/resources/dotfiles/electron-flags.conf" ~/.config/code-flags.conf
ln -si "$(pwd)/laptop/resources/dotfiles/electron-flags.conf" ~/.config/electron-flags.conf
```

## Packages

Requirements:
1. yay
2. pacdef

```shell
pacdef group import laptop/resources/pacdef/*
pacdef package sync
pacdef package clean
```
