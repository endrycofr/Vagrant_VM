#!/bin/bash

set -e

echo "===== ACTIVATE VENV ====="
source ~/kolla-venv/bin/activate

echo "===== INSTALL OPENSTACK CLI ====="
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master

echo "===== RUN KOLLA POST-DEPLOY ====="
kolla-ansible post-deploy -i ~/all-in-one

echo "===== SETUP OPENSTACK CLI CONFIG ====="
mkdir -p ~/.config/openstack
cp /etc/kolla/clouds.yaml ~/.config/openstack/clouds.yaml

echo "===== SET DEFAULT CLOUD ====="
if ! grep -q "OS_CLOUD=kolla-admin" ~/.bashrc; then
    echo "export OS_CLOUD=kolla-admin" >> ~/.bashrc
fi

echo "===== LOAD ENVIRONMENT ====="
source ~/.bashrc

echo "===== ADD USER TO DOCKER GROUP ====="
sudo usermod -aG docker $USER

echo "===== LOAD OPENSTACK ADMIN RC ====="
source /etc/kolla/admin-openrc.sh

echo "===== VERIFY OPENSTACK ====="

echo "--- Service List ---"
openstack service list || true

echo "--- Compute Service ---"
openstack compute service list || true

echo "--- Network Agent ---"
openstack network agent list || true

echo "--- Volume Service ---"
openstack volume service list || true

echo "===== DOCKER CONTAINERS ====="
docker ps

echo "===== GET ADMIN PASSWORD ====="
grep keystone_admin_password /etc/kolla/passwords.yml

echo "===== DONE ====="