.PHONY: up del vm_start vm_stop reboot

VM_NAME=k3s-master1 k3s-master2 k3s-master3

up:
	vagrant up

del:
	vagrant destroy -f

vm_start:
	@for vm in $(VM_NAME); do \
		echo "Starting $$vm ..."; \
		vagrant up $$vm; \
		sleep 5; \
	done

vm_stop:
	@for vm in $(VM_NAME); do \
		echo "Stopping $$vm ..."; \
		vagrant halt $$vm; \
		sleep 3; \
	done

reboot:
	@for vm in $(VM_NAME); do \
		echo "Rebooting $$vm ..."; \
		vagrant reload $$vm; \
		sleep 5; \
	done