# VPN server setup

Requires:
1. ansible
2. wireguard-tools (only for key generation)
3. xray-core (only for key generation)

`inventory.yaml`
```yaml
vpn:
  hosts:
    hostname1:
      vpn_wireguard_subnet_prefix_ip4: "10.0.0." # required
      vpn_wireguard_subnet_prefix_ip6: "fd00::0:" # required
      vpn_wireguard_port: 1234 # required
      vpn_wireguard_server_key: xxxxxx # required

      vpn_xray_server_key: xxxxxx # required

    hostname2:
      vpn_wireguard_subnet_prefix_ip4: "10.0.1."
      vpn_wireguard_subnet_prefix_ip6: "fd00::1:"
      vpn_wireguard_port: 1234
      vpn_wireguard_server_key: xxxxxx

      vpn_xray_server_key: xxxxxx
```

`vars.yaml`
```yaml
vpn_wireguard_server_ip_suffix: 1 # has default
vpn_wireguard_exporter_version: "3.6.6" # has default
vpn_wireguard_peers: # has default
  - key: xxxxxx
    ip_suffix: 2
    tags:
      name1: value1
      name2: value2

vpn_xray_version: "1.8.3" # has default
vpn_xray_checksum: "sha256:858a2f819acd29d21109f83b06ace5188d88c6487af8475a898bdb6b5f618421" # has default
vpn_xray_fake_url: "example.com" # has default
vpn_xray_short_ids: ["xxxxxx"] # has default
vpn_xray_peers: # has default
  - id: "00000000-0000-0000-0000-000000000000"
    email: "username1"
```

```shell
# generate a WireGuard key pair
vpn/gen-keys.sh

# generate a Xray short ID
openssl rand -hex 8

# generate a Xray key pair
xray x25519

ansible-playbook -i inventory.yaml \
                 vpn/10_system-init.yaml \
                 vpn/20_wireguard-init.yaml \
                 vpn/21_wireguard-prometheus_exporter.yaml \
                 vpn/30_squid-init.yaml \
                 vpn/40_xray-init.yaml
```
