#!/bin/sh

set -e

read_property() {
    if [ -e "vars.yaml" ]; then
        value=$(yq .$1 vars.yaml)
        if [ "$value" != "null" ]; then
            value=$(echo -n "$value" | tr -d '"')
            echo "$value"
            return
        fi
    fi

    if [ -e "defaults.yaml" ]; then
        value=$(yq .$1 defaults.yaml)
        if [ "$value" != "null" ]; then
            value=$(echo -n "$value" | tr -d '"')
            echo "$value"
            return
        fi
    fi

    echo "\"$1\" is not set in vars.yaml or defaults.yaml, exiting" >&2
    exit 1
}

hostname=$(read_property selfhosted_hostname)
storage_path=$(read_property selfhosted_storage_path)
backup_path=$(read_property selfhosted_backup_path)
seedbox_path=$(read_property selfhosted_seedbox_path)
seedbox_hostname=$(read_property seedbox_hostname)
transmission_ui_port=$(read_property seedbox_transmission_ui_port)

merged_manifest=""
for f in $(find selfhosted/kubernetes -name "*.yaml"); do
    manifest=$(cat "$f")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_hostname\s*}}#$hostname#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_storage_path\s*}}#$storage_path#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_backup_path\s*}}#$backup_path#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_seedbox_path\s*}}#$seedbox_path#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*seedbox_hostname\s*}}#$seedbox_hostname#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*seedbox_transmission_ui_port\s*}}#$transmission_ui_port#g")

merged_manifest="$merged_manifest
---
$manifest
"
done

echo "$merged_manifest" | kubectl apply -f -

kubectl apply -Rf ./selfhosted/secrets

for chart in $(find ./selfhosted/charts -mindepth 1 -maxdepth 1 -type d -exec basename {} \;); do
    if [ -f defaults.yaml ]; then values_defaults="--values defaults.yaml"; fi
    if [ -f vars.yaml ]; then values_vars="--values vars.yaml"; fi

    helm upgrade --install \
                 --atomic \
                 --cleanup-on-fail \
                 --history-max 1 \
                 $values_defaults \
                 $values_vars \
                 "$chart" "./selfhosted/charts/$chart"
done
