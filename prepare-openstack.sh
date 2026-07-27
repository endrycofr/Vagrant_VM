#!/bin/bash

set -e

echo "===== SYSTEM INFORMATION ====="
lsb_release -a || true
id

echo "===== SET PASSWORDLESS SUDO ====="
if ! sudo grep -q "ubuntu ALL=(ALL:ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "ubuntu ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
    echo "Sudoers updated"
else
    echo "Sudoers already configured"
fi

echo "===== HARDWARE INFO ====="
echo "CPU Cores:"
nproc

echo "Memory:"
free -mh

echo "===== CHECK VIRTUALIZATION SUPPORT ====="
egrep -c '(vmx|svm)' /proc/cpuinfo || true

echo "===== INSTALL KVM PACKAGES ====="
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils cpu-checker

echo "===== CHECK KVM AVAILABILITY ====="
kvm-ok || echo "KVM not available (expected if using VirtualBox without nested VT)"

echo "===== LOAD KVM MODULE (AMD/INTEL) ====="

if grep -q 'AuthenticAMD' /proc/cpuinfo; then
    echo "AMD CPU detected"
    sudo modprobe kvm-amd || true
    echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
    sudo modprobe -r kvm-amd || true
    sudo modprobe kvm-amd || true
    cat /sys/module/kvm_amd/parameters/nested || true

elif grep -q 'GenuineIntel' /proc/cpuinfo; then
    echo "Intel CPU detected"
    sudo modprobe kvm-intel || true
    echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.conf
    sudo modprobe -r kvm-intel || true
    sudo modprobe kvm-intel || true
    cat /sys/module/kvm_intel/parameters/nested || true

else
    echo "Unknown CPU type"
fi

echo "===== ADD USER TO LIBVIRT GROUP ====="
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

echo "===== FINAL CHECK ====="
echo "If using VirtualBox:"
echo "- Enable Nested VT-x/AMD-V from VM settings"
echo "- Expect KVM may not fully work"

echo "===== DONE ====="