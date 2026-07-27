#!/bin/bash

set -e

echo "===== DEPLOY OPENSTACK WITH KOLLA-ANSIBLE ====="
kolla-ansible bootstrap-servers -i ./all-in-one

echo "===== PRE-DEPLOYMENT CHECKS ====="
kolla-ansible prechecks -i ./all-in-one


echo "===== DEPLOY OPENSTACK ====="
kolla-ansible deploy -i ./all-in-one

echo "===== DONE  ====="