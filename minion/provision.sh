#!/bin/bash

sudo mkdir -p /etc/kubernetes
sudo mv /tmp/worker-kubeconfig.yaml /etc/kubernetes/worker-kubeconfig.yaml
sudo mv /tmp/kubelet.service /etc/systemd/system/kubelet.service

sudo systemctl daemon-reload

sudo systemctl start kubelet
sudo systemctl enable kubelet

sudo mv /tmp/kube-proxy.manifest.yaml /etc/kubernetes/manifests/kube-proxy.yaml