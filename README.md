# Infrastructure

A set of Ansible playbooks, Kubernetes manifests and shell scripts to setup the infrastructure that I use.

The infrastructure consists of:
1. Multiple Wireguard VDSs (CentOS 7) with shared configuration (it's possible to configure a separate subnet for each one so you can connect to all of them at the same time; *notice*: 10.0.1.0/24 subnet is not available because microk8s uses 10.0.1.1 as the host address)
2. A DNS server which shares a VDS with one of the Wireguard servers and is available only on the VPN network
3. A Kubernetes cluster on a Raspberry Pi 4B (4GB) with an external drive which hosts an *arr stack and some more cool stuff

One of the Wireguard servers is considered the "primary" one and is used to connect all other devices like my phone and laptop to the cluster ("which one" is determined by DNS and client VPN configuration).

You probably wouldn't want to use the Kubernetes manifests the way they are, but at you should be able to refer to them for inspiration.

*NOTICE*: everything (playbooks, scripts, ...) is meant to be run from the root directory of the repository!
