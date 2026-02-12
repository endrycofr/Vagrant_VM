.PHONY: up del vm_start vm_stop reset

VM_MASTER= k3s-master1 
VM_WORKER= k3s-worker1 k3s-worker2
VM_NAME= $(VM_MASTER) $(VM_WORKER)
up:
	vagrant up
del:
	vagrant destroy -f
vm_start:
	vagrant up $(VM_NAME)

vm_stop:
	vagrant halt $(VM_NAME)
reset:
	vagrant reload  k3s-master1 --provision