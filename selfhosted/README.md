# Kubernetes cluster setup

Requires:
1. ansible
2. kubectl
3. yq
4. openssh (for key generation)
5. helm

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

selfhosted_seedbox_path: /mnt/seedbox # has default
selfhosted_seedbox_ssh_port: 22 # has default
selfhosted_seedbox_ssh_user: root # has default
selfhosted_seedbox_ssh_key_path: /etc/ssh-keys/seedbox # has default

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

# --------

seedbox_hostname: seedbox.example # required
seedbox_storage_path: /home/user1/storage # required
seedbox_transmission_ui_port: 9091 # has default
```

If you're using a Raspberry Pi as the server, run `ansible-playbook -i inventory.yaml selfhosted/00_hw-rpi.yaml` and reboot before proceeding.

```shell
ansible-playbook -i inventory.yaml \
                 selfhosted/10_system-init.yaml \
                 selfhosted/11_system-wireguard-client.yaml \
                 selfhosted/12_system-connect-seedbox.yaml \
                 selfhosted/20_cluster-init.yaml \
                 selfhosted/21_cluster-auto-prune.yaml \
                 selfhosted/22_cluster-auto-backup.yaml \
                 selfhosted/29_cluster-pull-kubeconfig.yaml
```

## Cleanup

Some services come and go. To destroy whatever remains in the cluster for the ones that didn't fit my setup, use `selfhosted/cleanup-cluster.sh`.

*Notice*: removes de-commissioned stuff without any prompting and is very destructive.

## Connecting to seedbox

Currently there is no way to avoid configuring a valid seedbox connection. The seedbox should be already configured before deploying the cluster.

```shell
ssh-keygen -t ed25519 -f ./seedbox -P ""
```

1. Copy the private key to `/etc/ssh-keys/seedbox` (or whatever `selfhosted_seedbox_ssh_key_path` points to) on the "selfhosted" server
2. Add the public key to `~/.ssh/authorized_keys` on the "seedbox" server
3. SSH from the "selfhosted" server to the "seedbox" server to verify the connection and add it to selfhosted's `known_hosts`

## Gire / https://github.com/sibwaf/gire

1. Build the image and export it as a .tar file
2. Import the image into the cluster with `microk8s ctr image import --base-name sibwaf/gire:latest FILENAME`
3. Generate an SSH identity for Gire with `ssh-keygen -t ed25519 -f gire_id -P ""`

`selfhosted/secrets/gire.yaml`
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

`selfhosted/secrets/inuyama.yaml`
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

`selfhosted/secrets/gotify.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gotify
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx
```

## Gonic

Requires opening UI to create an account and configure scrobbling.

## Transmission

`selfhosted/secrets/transmission.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: transmission
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx
```

## Media: Lidarr, Sonarr, Radarr, Prowlarr

Requires opening UI to setup an account and configure.

### Configuring download clients

1. Navigate to Settings -> Download Clients.
2. Add a new client:
    * `host = seedbox-transmission-proxy`
    * `port = 80`
    * `username = ******`
    * `password = ******`
    * `category = ******` (set to app's name; ex: `lidarr`)
3. Add a path mapping for `seedbox-transmission-proxy`: `/full/path/on/seedbox/to/transmission/downloads` -> `/downloads/`

### Lidarr

1. Create an account
2. Add library `/library/Music` in Settings -> Media Management
3. Edit the default metadata profile in Settings -> Profiles to include EPs/singles/...
4. Add the download client
5. Grab the API key from Settings -> General

### Sonarr

1. Create an account
2. Add library `/library/TV` in Settings -> Media Management
3. Add wanted release groups in Settings -> Custom Formats
4. Set release group priorities for quality profiles in Settings -> Profiles
5. Add the download client
6. Grab the API key from Settings -> General

### Radarr

1. Create an account
2. Add library `/library/Movies` in Settings -> Media Management
3. Add the download client
4. Grab the API key from Settings -> General

### Prowlarr

1. Create an account
2. Add other apps in Settings -> Apps:
    * `sync = Full Sync`
    * `prowlarr = http://prowlarr`
    * `******** server = http://********`
    * `key = ********`
3. Add the download client with category mappings
    * Audio -> lidarr
    * TV -> sonarr
    * Movies -> radarr
4. Add desired indexers in Indexers

## Homer

`selfhosted/secrets/homer.yaml`
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

## VictoriaMetrics

`selfhosted/secrets/victoria-metrics.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: victoria-metrics
type: Opaque
stringData:
  username: xxxxxx
  password: xxxxxx

  PROMETHEUS_SCRAPE_1: name=address
  PROMETHEUS_SCRAPE_2: name=address
  PROMETHEUS_LABELS_2: a=b;c=d
```

## Grafana
`selfhosted/secrets/grafana.yaml`
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
