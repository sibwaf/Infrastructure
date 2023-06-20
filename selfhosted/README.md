# Kubernetes cluster setup

Requires:
1. ansible
2. kubectl
3. yq

`inventory.yaml`
```yaml
selfhosted:
  hosts:
    hostname1:
    hostname2:
```

`vars.yaml`
```yaml
selfhosted_swap_size: 1024 # has default

selfhosted_hostname: cluster.example # required

selfhosted_storage_partition_uuid: xxxxxx # optional
selfhosted_storage_path: /mnt/storage # has default
selfhosted_backup_partition_uuid: xxxxxx # optional
selfhosted_backup_path: /mnt/backup # has default
selfhosted_backup_password: xxxxxx # required

selfhosted_network_ip: "192.168.1.2/24" # required
selfhosted_network_gateway: "192.168.11.1" # required
selfhosted_network_dns: ["1.1.1.1", "1.0.0.1"] # required

selfhosted_vpn_client_key: xxxxxx # required
selfhosted_vpn_servers: # has default
  - endpoint: "127.0.0.1:1234"
    server_key: xxxxxx
    ip4: "10.0.0.2"
    ip4_subnet: "10.0.0.0/24"
    ip6: "fd00::2"
    ip6_subnet: "fd00::0/112"
    dns: ["1.1.1.1", "1.0.0.1"]

selfhosted_cri_tools_version: "1.2.3"
selfhosted_cri_tools_checksum: "sha256:0000000000000000000000000000000000000000000000000000000000000000"
```

If you're using a Raspberry Pi as the server, run `ansible-playbook -i inventory.yaml selfhosted/00_hw-rpi.yaml` and reboot before proceeding.

```shell
ansible-playbook -i inventory.yaml \
                 selfhosted/10_system-init.yaml \
                 selfhosted/11_system-wireguard-client.yaml \
                 selfhosted/20_cluster-init.yaml \
                 selfhosted/21_cluster-auto-prune.yaml \
                 selfhosted/29_cluster-pull-kubeconfig.yaml
```

## Gire / https://github.com/sibwaf/gire

1. Build the image and export it as a .tar file
2. Import the image into the cluster with `microk8s ctr image import --base-name sibwaf/gire:latest FILENAME`
3. Generate an SSH identity for Gire with `ssh-keygen -t ed25519 -f gire_id -P ""`

`selfhosted/kubernetes/secrets/gire.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gire
type: Opaque
stringData:
  id: | # the private key contents
    xxxxxx

  trusted.pub: | # ssh-keyscan github.com
    xxxxxx
    xxxxxx

  sources.yaml: |
    - url: https://github.com/USERNAME
      type: github
      authToken: xxxxxx
```

## Inuyama

1. Build the image and export it as a .tar file
2. Import the image into the cluster with `microk8s ctr image import --base-name sibwaf/inuyama:latest FILENAME`
3. Generate the server key and encode it with Base64:
```shell
kubectl run inuyama-temp --image-pull-policy=Never --image sibwaf/inuyama:latest
kubectl exec inuyama-temp -- /bin/sh -c "cat /app/server.key | base64"
kubectl delete pod inuyama-temp
```

`selfhosted/kubernetes/secrets/inuyama.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: inuyama
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx
data:
  server.key: |
    xxxxxx
```

## Homebox

Requires opening UI to create an account.

## Gotify

`selfhosted/kubernetes/secrets/gotify.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gotify-credentials
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx
```

## Gonic

Requires opening UI to create an account and configure scrobbling.

## Samba

`selfhosted/kubernetes/secrets/samba.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: samba-credentials
type: Opaque
stringData:
  ACCOUNT_usernamehere: passwordhere
```

## Transmission

`selfhosted/kubernetes/secrets/transmission.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: transmission-credentials
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx
```

## Deluge

Requires opening UI to configure:
1. The default password is `deluge`, change it in UI Preferences -> Interface
2. Enable `Label` plugin in Preferences -> Plugins

## Media: Lidarr, Sonarr, Radarr, Prowlarr

Requires opening UI to setup an account and configure.

### Lidarr

1. Create an account
2. Add library `/library/Music` in Settings -> Media Management
3. Edit the default metadata profile in Settings -> Profiles to include EPs/singles/...
4. Add Deluge in Settings -> Download Clients:
    * `host = deluge`
    * `port = 80`
    * `password = ********`
    * `category = lidarr`
5. Add path mapping `/downloads/ -> /library/Downloads/`
6. Grab the API key from Settings -> General

### Sonarr

1. Create an account
2. Add library `/library/TV` in Settings -> Media Management
3. Add wanted release groups in Settings -> Custom Formats
4. Set release group priorities for quality profiles in Settings -> Profiles
5. Add Transmission in Settings -> Download Clients:
    * `host = deluge`
    * `port = 80`
    * `password = ********`
    * `category = sonarr`
6. Add path mapping `/downloads/ -> /library/Downloads/`
7. Grab the API key from Settings -> General

### Radarr

1. Create an account
2. Add library `/library/Movies` in Settings -> Media Management
3. Add Transmission in Settings -> Download Clients:
    * `host = deluge`
    * `port = 80`
    * `password = ********`
    * `category = radarr`
4. Add path mapping `/downloads/ -> /library/Downloads/`
5. Grab the API key from Settings -> General

### Prowlarr

1. Create an account
2. Add other apps in Settings -> Apps:
    * `sync = Full Sync`
    * `prowlarr = http://prowlarr`
    * `******** server = http://********`
    * `key = ********`
3. Add desired indexers in Indexers

## Homer

`selfhosted/kubernetes/secrets/homer.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: homer
type: Opaque
stringData:
  PROWLARR_TOKEN: xxxxxx
  LIDARR_TOKEN: xxxxxx
  SONARR_TOKEN: xxxxxx
  RADARR_TOKEN: xxxxxx
```

## Syncthing

Requires opening UI to configure.

## Prometheus

`selfhosted/kubernetes/secrets/prometheus.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: prometheus
type: Opaque
stringData:
  PROMETHEUS_SCRAPE_1: name=address
```

## Grafana
`selfhosted/kubernetes/secrets/grafana.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana
type: Opaque
stringData:
  GF_SECURITY_ADMIN_USER: xxxxxx
  GF_SECURITY_ADMIN_PASSWORD: xxxxxx
```
