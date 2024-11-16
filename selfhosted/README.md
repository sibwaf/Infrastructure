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

selfhosted_gire_private_key: | # required
  -----BEGIN OPENSSH PRIVATE KEY-----
  xxxxxx
  -----END OPENSSH PRIVATE KEY-----
selfhosted_gire_known_hosts: # required
  - github.com ssh-rsa xxxxxx
selfhosted_gire_sources: # required
  - url: xxxxxx

selfhosted_gotify_username: xxxxxx # required
selfhosted_gotify_password: xxxxxx # required

selfhosted_grafana_username: xxxxxx # required
selfhosted_grafana_password: xxxxxx # required

selfhosted_immich_pgusername: xxxxxx # required
selfhosted_immich_pgpassword: xxxxxx # required

selfhosted_inuyama_username: xxxxxx # required
selfhosted_inuyama_password: xxxxxx # required
selfhosted_inuyama_exchangeratehost_token: xxxxxx # required
selfhosted_inuyama_server_key: | # required
  base64
  encoded
  key

selfhosted_lidarr_token: xxxxxx # required

selfhosted_prowlarr_token: xxxxxx # required

selfhosted_radarr_token: xxxxxx # required

selfhosted_sonarr_token: xxxxxx # required

selfhosted_transmission_username: xxxxxx # required
selfhosted_transmission_password: xxxxxx # required

selfhosted_victoriametrics_username: xxxxxx # required
selfhosted_victoriametrics_password: xxxxxx # required
selfhosted_victoriametrics_scrapes: # has default
  - name: cluster-host # required
    address: 10.0.1.1:9100 # required
    labels: # optional
      label_name: label_value

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

`vars.yaml`
```yaml
selfhosted_gire_private_key: | # the private key contents
  -----BEGIN OPENSSH PRIVATE KEY-----
  xxxxxx
  -----END OPENSSH PRIVATE KEY-----
selfhosted_gire_known_hosts: # ssh-keyscan github.com
  - github.com ssh-rsa xxxxxx
selfhosted_gire_sources: # see gire's readme
  - url: xxxxxx
```

## Inuyama / https://github.com/sibwaf/Inuyama

1. Build the image and export it as a .tar file
2. Import the image into the cluster with `microk8s ctr image import --base-name sibwaf/inuyama:latest FILENAME`
3. Generate the server key and encode it with Base64:
```shell
kubectl run inuyama-temp --image-pull-policy=Never --image sibwaf/inuyama:latest
kubectl exec inuyama-temp -- /bin/sh -c "cat /app/server.key | base64"
kubectl delete pod inuyama-temp
```
4. Register at https://exchangerate.host and get an access token

`vars.yaml`
```yaml
selfhosted_inuyama_username: xxxxxx
selfhosted_inuyama_password: xxxxxx
selfhosted_inuyama_exchangeratehost_token: xxxxxx
selfhosted_inuyama_server_key: |
  base64
  encoded
  key
```

## Homebox

Requires opening UI to create an account.

## Gotify

Configure the initial admin username/password and setup application/client tokens via UI.

`vars.yaml`
```yaml
selfhosted_gotify_username: xxxxxx
selfhosted_gotify_password: xxxxxx
```

## Gonic

Requires opening UI to create an account and configure scrobbling.

## Jellyfin

Required opening UI to create an account and configure libraries. Media is mounted to `/library`.

## Transmission

Configure the credentials.

`vars.yaml`
```yaml
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

## Immich

Configure the database credentials.

`vars.yaml`
```yaml
selfhosted_immich_pgusername: xxxxxx
selfhosted_immich_pgpassword: xxxxxx
```

Requires opening UI to configure everything else.

## Homer

*arr tokens can be found in Settings -> General in matching services.

`vars.yaml`
```yaml
selfhosted_lidarr_token: xxxxxx

selfhosted_prowlarr_token: xxxxxx

selfhosted_radarr_token: xxxxxx

selfhosted_sonarr_token: xxxxxx
```

## Syncthing

Requires opening UI to configure.

## VictoriaMetrics

Configure the credentials and Prometheus scrapes.

`vars.yaml`
```yaml
selfhosted_victoriametrics_username: xxxxxx
selfhosted_victoriametrics_password: xxxxxx
selfhosted_victoriametrics_scrapes:
  - name: job-name
    address: 1.2.3.4:9100
    labels:
      abc: xyz
```

## Grafana

Configure the admin credentials.

`vars.yaml`
```yaml
selfhosted_grafana_username: xxxxxx
selfhosted_grafana_password: xxxxxx
```
