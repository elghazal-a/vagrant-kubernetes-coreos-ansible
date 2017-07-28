#!/bin/bash


sudo mv /tmp/kubelet.service /etc/systemd/system/kubelet.service


sudo systemctl daemon-reload

sudo systemctl start kubelet
sudo systemctl enable kubelet


sudo mv /tmp/kube-apiserver.manifest.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
sudo mv /tmp/kube-proxy.manifest.yaml /etc/kubernetes/manifests/kube-proxy.yaml
sudo mv /tmp/kube-controller-manager.manifest.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo mv /tmp/kube-scheduler.manifest.yaml /etc/kubernetes/manifests/kube-scheduler.yaml
