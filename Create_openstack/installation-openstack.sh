#!/bin/bash

set -e

echo "===== UPDATE SYSTEM ====="
sudo apt update && sudo apt upgrade -y

echo "===== INSTALL DEPENDENCIES ====="
sudo apt install -y \
  git python3-dev libffi-dev gcc libssl-dev \
  libdbus-glib-1-dev python3-venv python3-pip

echo "===== CREATE VENV ====="
python3 -m venv ~/kolla-venv
source ~/kolla-venv/bin/activate

echo "===== UPGRADE PIP ====="
pip install -U pip

echo "===== INSTALL PYTHON PACKAGES ====="
pip install docker pkgconfig dbus-python

echo "===== INSTALL KOLLA-ANSIBLE (STABLE YOGA) ====="
pip install 'kolla-ansible>=19.0.0,<20.0.0'
pip install 'ansible-core>=2.16.0,<2.17.0'

echo "===== SETUP KOLLA DIR ====="
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

cp -r ~/kolla-venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ~/kolla-venv/share/kolla-ansible/ansible/inventory/all-in-one ~/all-in-one

echo "===== INSTALL ANSIBLE DEPENDENCIES ====="
kolla-ansible install-deps

echo "===== GENERATE PASSWORDS ====="
kolla-genpwd

echo "===== DONE ====="