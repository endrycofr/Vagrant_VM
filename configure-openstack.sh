#!/bin/bash

set -e

echo "===== CONFIGURE /etc/kolla/globals.yml ====="

sudo tee /etc/kolla/globals.yml > /dev/null <<EOF
# Kolla base
kolla_base_distro: "ubuntu"
kolla_install_type: "source"

# Network
network_interface: "eth2"
kolla_internal_vip_address: "192.168.56.100"

neutron_external_interface: "eth1"

# Virtualization (VirtualBox fix)
nova_compute_virt_type: "qemu"

# Horizon Dashboard
enable_horizon: "yes"

# Cinder Block Storage
enable_cinder: "yes"
enable_cinder_backend_lvm: "yes"
EOF

echo "===== DONE CONFIG ====="
echo "Check file:"
echo "cat /etc/kolla/globals.yml"