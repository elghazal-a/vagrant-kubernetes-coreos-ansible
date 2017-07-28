# Kubernetes cluster setup on top of CoreOS with Vagrant.

This is automated setup to run quickly a cluster of K8S on top of CoreOS for testing purposes. It's tested only on MAC OS and supports only virtualbox as provider.

## Install kubectl command line to interact with the cluster

```bash
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/darwin/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```

## Set up the cluster

Setting up the cluster is as easy as running `vagrant up`. It will set up 1 `master`, 1 `minion` and a `proxy` machine. You can change the number of `minions` by setting `MINION_COUNT` environement variable.

```bash
vagrant up
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

The `proxy` runs `HAProxy` that listens on `8080` (kube-apiserver) and `2379` (etcd) ports. `minions` and `kubectl` cli communicate with master through the `proxy`. The `proxy` is mandatory only when building high-available master. 


If you want to configure automatically `kubectl` CLI to communicate with the cluster, set the `CONFIG_KUBELET` environment variable to `true`. It will configure `kubectl` CLI to point to `proxy` server.

```bash
export CONFIG_KUBELET=true 
vagrant up
```

You can check now your cluster nodes

```bash
kubectl get nodes
kubectl cluster-info
```
With the second command you will get the link to check the content of your master.

You can install k8s dashboard and kube-dns quickly
```bash
kubectl create -f resources/addons/
```
In order to see the dashboard you need to follow these commands. The first one will give you the version of kubernetes-dashboard to use in the second command.
```bash
kubectl get pods --namespace=kube-system
kubectl port-forward kubernetes-dashboard-v1.4.1-7034x 9090 --namespace=kube-system
```
You can check the dashboard on this link http://127.0.0.1:9090/ . You can take the dashboard tour to understand it more 
