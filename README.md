## Kubeadm Playbook
Ansible playbook that creates the latest version of Kubernetes 1.3x of instance running on CentOS or Debian.
### Prerequisites

- A host that can run docker/podman or an existing kubernetes cluster.

### Setup Ansible
```
$ git clone https://github.com/mcbtaguiad/kubeadm-ansible.git
$ cd kubeadm-ansible

# run with docker
$ docker compose up ansible -d

# exec to container
$ docker exec -it ansible bash
```

### Inventory
Use this sample inventory template (inventory/host.yaml). 
Add host variable in (inventory/group_vars/all.yaml)
##### Single Master Cluster
```
all:
  hosts:
    master1:
      ansible_ssh_host: 10.0.0.1
    worker1:
      ansible_ssh_host: 10.0.0.2
    worker2:
      ansible_ssh_host: 10.0.0.3
master:
  hosts:
    master1:
      ansible_ssh_host: 10.0.0.1

worker:
  hosts:
    worker1:
      ansible_ssh_host: 10.0.0.2
    worker2:
      ansible_ssh_host: 10.0.0.3
```
##### Multi Master Cluster
*Note: Need at least 3 master nodes for high availability cluster*
```
all:
  hosts:
    master1:
      ansible_ssh_host: 10.0.0.1
    master2:
      ansible_ssh_host: 10.0.0.2
    master3:
      ansible_ssh_host: 10.0.0.3
    worker1:
      ansible_ssh_host: 10.0.0.4
    worker2:
      ansible_ssh_host: 10.0.0.5
master:
  hosts:
    master1:
      ansible_ssh_host: 10.0.0.1
    master2:
      ansible_ssh_host: 10.0.0.2
    master3:
      ansible_ssh_host: 10.0.0.3
worker:
  hosts:
    worker1:
      ansible_ssh_host: 10.0.0.4
    worker2:
      ansible_ssh_host: 10.0.0.5
```
### Playbook
#### Init Cluster
```
$ ansible-playbook playbook/kubeadm_init.yaml -i inventory/hosts.yaml 
```

### Add Node to Existing Cluster
#### Add Master Node
Edit inventory file.
```
all:
  hosts:
    existing_master:
      ansible_ssh_host: 10.0.0.1
    new_master:
      ansible_ssh_host: 10.0.0.2

master:
  hosts:
    existing_master:
      ansible_ssh_host: 10.0.0.1
    new_master:
      ansible_ssh_host: 10.0.0.2
```

Run playbook
```
$ ansible-playbook playbook/add_node.yaml -i inventory/host.yaml
```

#### Add Worker Node
Edit host file.
```
all:
  hosts:
    existing_master:
      ansible_ssh_host: 10.0.0.1
    new_worker:
      ansible_ssh_host: 10.0.0.2
      
master:
  hosts:
    existing_master:
      ansible_ssh_host: 10.0.0.1


master:
  hosts:
    new_worker:
      ansible_ssh_host: 10.0.0.2
```

Run playbook
```
$ ansible-playbook playbook/add_node.yaml -i inventory/host.yaml
```

