# Seedbox setup

Assuming Debian 10 without root access on a shared multi-user VPS.

Requires Transmission to be already installed on the machine - usually through the seedbox provider's control panel.

Requires:
1. ansible

`inventory.yaml`
```yaml
seedbox:
  hosts:
    hostname1:
    hostname2:
```

`vars.yaml`
```yaml
seedbox_storage_path: /home/user1/storage # required
seedbox_transmission_download_path: /home/user1/downloads # required
```

```shell
ansible-playbook -i inventory.yaml seedbox/20_apps-transmission.yaml
```
