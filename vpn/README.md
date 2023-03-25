# VPN server setup

Requires:
1. ansible
2. wireguard-tools (only for key generation)

`inventory.yaml`
```yaml
vpn:
  hosts:
    hostname1:
      vpn_subnet_prefix_ip4: "10.0.0." # required
      vpn_subnet_prefix_ip6: "fd00::0:" # required
      vpn_port: 1234 # required
      vpn_server_key: xxxxxx # required
    hostname2:
      vpn_subnet_prefix_ip4: "10.0.1."
      vpn_subnet_prefix_ip6: "fd00::1:"
      vpn_port: 1234
      vpn_server_key: xxxxxx
```

`vars.yaml`
```yaml
vpn_server_ip_suffix: 1 # has default
vpn_wireguard_exporter_version: "3.6.6" # has default
vpn_peers: # has default
  - key: xxxxxx
    ip_suffix: 2
    tags:
      name1: value1
      name2: value2
```

```shell
ansible-playbook -i inventory.yaml \
                 vpn/10_system-init.yaml \
                 vpn/20_wireguard-init.yaml \
                 vpn/21_wireguard-prometheus_exporter.yaml \
                 vpn/30_squid-init.yaml
```

You can generate Wireguard keypairs with `vpn/gen-keys.sh`.
