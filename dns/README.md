# DNS server setup

Requires:
1. ansible

`inventory.yaml`
```yaml
dns:
  hosts:
    hostname1:
    hostname2:
```

`vars.yaml`
```yaml
dns_records: # has default
  "host1.xyz":
    ip4: "10.1.2.3" # optional
    ip6: "fd00::1:2:3" # optional
```

```shell
ansible-playbook -i inventory.yaml dns/setup.yaml
```
