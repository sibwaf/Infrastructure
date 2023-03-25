#!/bin/sh

private=$(wg genkey)
echo "Private: $private"
public=$(echo -n $private | wg pubkey)
echo "Public: $public"
