#!/bin/sh

kube_delete() {
    kubectl delete "$1" "$2" --ignore-not-found
}

# navidrome
kube_delete ingress navidrome
kube_delete service navidrome
kube_delete deployment navidrome
kube_delete pvc navidrome

# prometheus
kube_delete ingress prometheus
kube_delete service prometheus
kube_delete deployment prometheus
kube_delete secret prometheus
kube_delete pvc prometheus

# gotify
kube_delete secret gotify-credentials

# transmission
kube_delete secret transmission-credentials
