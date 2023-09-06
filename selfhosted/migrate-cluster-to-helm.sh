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

# inuyama
make_managed persistentvolumeclaim inuyama-backups inuyama
delete_if_unmanaged ingress inuyama
delete_if_unmanaged service inuyama
delete_if_unmanaged deployment inuyama
