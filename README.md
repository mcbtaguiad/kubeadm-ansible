## Kubeadm Playbook
Ansible playbook to create K8S and k3s cluster. 
### Prerequisites
- A host that can run docker/podman or an existing kubernetes cluster.
- One or more nodes/vm for the k8s cluster.

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
Use this sample inventory template (inventory/hosts.ini). 
##### Single Master Cluster
```
[all]
master01 ansible_host=192.168.254.201 ansible_user=mcbtaguiad
worker01 ansible_host=192.168.254.204 ansible_user=mcbtaguiad
worker02 ansible_host=192.168.254.205 ansible_user=mcbtaguiad

[master]
master01 ansible_host=192.168.254.201 ansible_user=mcbtaguiad

[worker]
worker01 ansible_host=192.168.254.204 ansible_user=mcbtaguiad
worker02 ansible_host=192.168.254.205 ansible_user=mcbtaguiad
```
##### Multi Master Cluster
*Note: Need at least 3 master nodes for high availability cluster*
```
[all]
master01 ansible_host=192.168.254.201 ansible_user=mcbtaguiad
master02 ansible_host=192.168.254.202 ansible_user=mcbtaguiad
master03 ansible_host=192.168.254.203 ansible_user=mcbtaguiad
worker01 ansible_host=192.168.254.204 ansible_user=mcbtaguiad
worker02 ansible_host=192.168.254.205 ansible_user=mcbtaguiad

[master]
master01 ansible_host=192.168.254.201 ansible_user=mcbtaguiad
master02 ansible_host=192.168.254.202 ansible_user=mcbtaguiad
master03 ansible_host=192.168.254.203 ansible_user=mcbtaguiad

[worker]
worker01 ansible_host=192.168.254.204 ansible_user=mcbtaguiad
worker02 ansible_host=192.168.254.205 ansible_user=mcbtaguiad
```
### Cluster Config
Enable what you need in you k8s cluster. By default, it is configured with Calico for CNI and Rook-Ceph for CSI. Also Metallb is enabled in the addon role, if you need Ingress Controller then you might need to install that separately. Check the repo for full variable and applications available to install. 

*kubeadm_init.yaml
```yaml
# ============================================================================ #
# Author: Mark Taguiad <marktaguiad@marktaguiad.dev>
# ============================================================================ #
- hosts: all
  become: true
  vars:
    HOST_COUNT: "{{ ansible_play_hosts | length }}"
    KUBECONFIG: /etc/kubernetes/admin.conf

  tasks:

    - name: Run sys role
      include_role:
        name: sys

    - name: Run k8s role
      include_role:
        name: k8s
      vars:
        K8S_VERSION: v1.35

    - name: Wait 30 seconds
      pause:
        seconds: 30

    - name: Run cni role
      include_role:
        name: cni
      vars:
        CNI_PLUGIN_VERSION: v1.9.0
        CALICO_VERSION: v3.31.4
        FLANNEL_VERSION: v0.28.1
        apps_enabled:
          - calico
          # - flannel

    - name: Wait 30 seconds
      pause:
        seconds: 30

    - name: Run csi role
      include_role:
        name: csi
      vars:
        LONGHORN_VERSION: v1.11.0
        ROOK_VERSION: v1.19.2
        apps_enabled:
          - rook-ceph
          # - longhorn

    - name: Wait 60 seconds
      pause:
        seconds: 60

    - name: Run addons role
      include_role:
        name: addons
      vars:
        METALLB_VERSION: v0.15.3
        METALLB_IP_RANGE: "192.168.254.220-192.168.254.250"
        apps_enabled:
          - metallb
          - kube-state-metrics
          - metrics-server
          - headlamp
```

### Playbook
#### Init Cluster
```
$ ansible-playbook playbook/kubeadm_init.yaml -i inventory/hosts.ini 
```

### k3s
For older or less powerful system, consider using k3s. The repo is focused on kubeadm, some error might be encountered if using this k3s playbook.
```
$ ansible-playbook playbook/k3s_install.yaml -i inventory/hosts.ini 
```
