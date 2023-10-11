#!/bin/sh

patch_if_exists() {
    kind="$1"
    name="$2"
    patch="$3"

    kubectl get "$kind" "$name" > /dev/null 2>&1 && kubectl patch "$kind" "$name" --patch "$patch"
}

make_managed() {
    kind="$1"
    name="$2"
    release="$3"

    patch='{"metadata":{"labels":{"app.kubernetes.io/managed-by":"Helm"},"annotations":{"meta.helm.sh/release-name":"'
    patch+="$release"
    patch+='","meta.helm.sh/release-namespace":"default"}}}'

    patch_if_exists "$kind" "$name" "$patch"
}

delete_if_unmanaged() {
    kind="$1"
    name="$2"

    managed_by=$(kubectl get "$kind" "$name" -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null)

    if [ "$managed_by" != "Helm" ]; then
        kubectl delete "$kind" "$name" --ignore-not-found
    fi
}

# gire
make_managed persistentvolumeclaim gire gire
delete_if_unmanaged deployment gire

# gonic
make_managed persistentvolumeclaim gonic gonic
delete_if_unmanaged ingress gonic
delete_if_unmanaged service gonic
delete_if_unmanaged deployment gonic

# gotify
make_managed persistentvolumeclaim gotify gotify
delete_if_unmanaged ingress gotify
delete_if_unmanaged service gotify
delete_if_unmanaged deployment gotify

# grafana
delete_if_unmanaged ingress grafana
delete_if_unmanaged service grafana
delete_if_unmanaged deployment grafana
delete_if_unmanaged configmap grafana

# homebox
make_managed persistentvolumeclaim homebox homebox
delete_if_unmanaged ingress homebox
delete_if_unmanaged service homebox
delete_if_unmanaged deployment homebox

# homer
delete_if_unmanaged ingress homer
delete_if_unmanaged service homer
delete_if_unmanaged deployment homer
delete_if_unmanaged configmap homer

# inuyama
make_managed persistentvolumeclaim inuyama-backups inuyama
delete_if_unmanaged ingress inuyama
delete_if_unmanaged service inuyama
delete_if_unmanaged deployment inuyama

# lidarr
make_managed persistentvolumeclaim lidarr lidarr
delete_if_unmanaged ingress lidarr
delete_if_unmanaged service lidarr
delete_if_unmanaged deployment lidarr

# prowlarr
make_managed persistentvolumeclaim prowlarr prowlarr
delete_if_unmanaged ingress prowlarr
delete_if_unmanaged service prowlarr
delete_if_unmanaged deployment prowlarr

# radarr
make_managed persistentvolumeclaim radarr radarr
delete_if_unmanaged ingress radarr
delete_if_unmanaged service radarr
delete_if_unmanaged deployment radarr

# sonarr
make_managed persistentvolumeclaim sonarr sonarr
delete_if_unmanaged ingress sonarr
delete_if_unmanaged service sonarr
delete_if_unmanaged deployment sonarr

# syncthing
make_managed persistentvolumeclaim syncthing syncthing
delete_if_unmanaged ingress syncthing
delete_if_unmanaged service syncthing
delete_if_unmanaged deployment syncthing

# transmission
make_managed persistentvolumeclaim transmission transmission
delete_if_unmanaged ingress transmission
delete_if_unmanaged service transmission
delete_if_unmanaged deployment transmission

# victoria-metrics
make_managed persistentvolumeclaim victoria-metrics victoria-metrics
delete_if_unmanaged ingress victoria-metrics
delete_if_unmanaged service victoria-metrics
delete_if_unmanaged deployment victoria-metrics
