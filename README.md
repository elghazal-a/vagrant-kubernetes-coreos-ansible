# Kubernetes cluster setup on top of CoreOS with Vagrant.

NOTE: Check `HA` branch if you want to setup a `highly available` k8s cluster (multiple masters)

This is automated setup to run quickly K8S cluster on top of CoreOS for testing purposes. it supports only virtualbox as virtualisation provider and it's tested on 

* Debian Jessie
* Vagrant 1.9.5

## Requirements

You need to install in the host machine
* `Ansible` used for VM provisioning
* `kubectl` to interact with k8s cluster

## Set up the cluster

Setting up the cluster is as easy as running `vagrant up`. It will set up by default 1 `master`, 1 `minion`. You can change the number of `minions` by setting `MINION_COUNT` environement variable.

```bash
MINION_COUNT=1 vagrant up
````
The `master` will run the following components:
* Kubelet: It runs outside of Docker but always as container using `rkt`
* kube-apiserver: it runs as pods using `kubelet`
* kube-scheduler: it runs as pods using `kubelet`
* kube-controller-manager: it runs as pods using `kubelet`
* kube-proxy: it runs as pods using `kubelet`


The `minion` will run the following components:
* Kubelet: It runs outside of Docker but always as container using `rkt`
* kube-proxy: it runs as pods using `kubelet`

The `proxy` will runs:
* `HAProxy` 
* It listens on `8080` (kube-apiserver) and `2379` (etcd) ports. 
* It loadbalances traffic across the different k8s masters


If you want to configure automatically `kubectl` CLI to communicate with the cluster, set the `CONFIG_KUBELET` environment variable to `true`. It will configure `kubectl` CLI to point to `proxy` server.

```bash
CONFIG_KUBELET=true  vagrant up
```

You can check now your cluster nodes

```bash
kubectl get nodes
kubectl cluster-info
```
