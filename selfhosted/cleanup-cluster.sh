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

# kubernetes-dashboard
kube_delete namespace kubernetes-dashboard
kube_delete clusterrolebinding admin-user
kube_delete clusterrolebinding kubernetes-dashboard
kube_delete clusterrole kubernetes-dashboard

# deluge
kube_delete ingress deluge
kube_delete service deluge
kube_delete deployment deluge
kube_delete pvc deluge

# samba
kube_delete deployment samba
kube_delete secret samba-credentials

# grafana
kube_delete configmap grafana-dashboard-vpn
kube_delete configmap grafana-dashboard-node-exporter
