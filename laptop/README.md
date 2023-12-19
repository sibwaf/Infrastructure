# Laptop setup

ArchLinux with GNOME, full disk encryption and systemd-boot/UKI boot.

## Playbooks

`inventory.yaml`
```yaml
laptop:
  hosts:
    localhost:
      ansible_connection: local # if SSH is disabled
```

### Networking

NetworkManager + dnsmasq for DNS resolving.

`vars.yaml`
```yaml
laptop_dns_mapping: # has default
  - name: ".example.com" # *.example.com
    address: "0.0.0.0"
  - name: "example.com" # example.com
    address: "0.0.0.0"
```

```shell
ansible-playbook -K -i inventory.yaml laptop/networking.yaml
```

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

mkdir -p ~/.config/wireplumber/policy.lua.d
ln -si "$(pwd)/laptop/resources/dotfiles/wireplumber/policy.lua.d/11-bluetooth-policy.lua" ~/.config/wireplumber/policy.lua.d/11-bluetooth-policy.lua

ln -si "$(pwd)/laptop/resources/dotfiles/electron-flags.conf" ~/.config/code-flags.conf
ln -si "$(pwd)/laptop/resources/dotfiles/electron-flags.conf" ~/.config/electron-flags.conf

ln -si "$(pwd)/laptop/resources/dotfiles/alsoft.conf" ~/.config/alsoft.conf
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
