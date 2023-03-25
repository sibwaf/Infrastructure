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

merged_manifest=""
for f in $(find selfhosted/kubernetes -name "*.yaml"); do
    manifest=$(cat "$f")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_hostname\s*}}#$hostname#g")
    manifest=$(echo "$manifest" | sed "s#{{\s*selfhosted_storage_path\s*}}#$storage_path#g")

merged_manifest="$merged_manifest
---
$manifest
"
done

echo "$merged_manifest" | kubectl apply -f -
