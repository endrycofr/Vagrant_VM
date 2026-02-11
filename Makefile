.PHONY: up del vm_start vm_stop reset

VM_NAME= k3s-master1 k3s-master2 k3s-master3 

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