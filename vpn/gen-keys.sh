#!/bin/sh

private=$(wg genkey)
echo "Private: $private"
public=$(printf "%s" "$private" | wg pubkey)
echo "Public: $public"
