# -*- mode: ruby -*-
# vi: set ft=ruby :

UPDATE_CHANNEL = "stable"
COREOS_VERSION = "1409.7.0"
MASTER_COUNT = 1
MINION_COUNT = (ENV['MINION_COUNT'] || 0).to_i

CONFIG_KUBELET  = ENV['CONFIG_KUBELET'] || false

PROXY_IP = "172.17.4.100"

def masterIP(num)
  return "172.17.4.#{num+100}"
end

def minionIP(num)
  return "172.17.4.#{num+200}"
end

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.define vm_proxy_name = "proxy" do |proxy|

    proxy.vm.box = "hashicorp/precise64"
    proxy.vm.hostname = vm_proxy_name

    proxy.vm.provider "virtualbox" do |vb|
      vb.memory = "128"
    end

    proxy.vm.network :private_network, ip: "#{PROXY_IP}"
    proxy.vm.network "forwarded_port", guest: 8080, host: 8080
    proxy.vm.network "forwarded_port", guest: 8888, host: 8888
    
    proxy.vm.provision :file, :source => "./proxy/haproxy.cfg", :destination => "/tmp/haproxy.cfg"
    proxy.vm.provision :shell, :path => "proxy/provision.sh", :privileged => true
  end

  (1..MASTER_COUNT).each do |i|
    config.vm.define vm_master_name = "master-%d" % i do |master|

      master.vm.box = "coreos-%s" % UPDATE_CHANNEL
      master.vm.box_url = "http://#{UPDATE_CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_vagrant.json"
    
      master.vm.hostname = vm_master_name
      master.vm.network :private_network, ip: masterIP(i)

      master.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end

      
      master.vm.provision :file, :source => "./master/cloud-config.yml", :destination => "/tmp/vagrantfile-user-data"
      master.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true

      master.vm.provision :file, :source => "./master/kubelet.service", :destination => "/tmp/kubelet.service"
      master.vm.provision :file, :source => "./master/kube-apiserver.manifest.yaml", :destination => "/tmp/kube-apiserver.manifest.yaml"
      master.vm.provision :file, :source => "./master/kube-proxy.manifest.yaml", :destination => "/tmp/kube-proxy.manifest.yaml"
      master.vm.provision :file, :source => "./master/kube-controller-manager.manifest.yaml", :destination => "/tmp/kube-controller-manager.manifest.yaml"
      master.vm.provision :file, :source => "./master/kube-scheduler.manifest.yaml", :destination => "/tmp/kube-scheduler.manifest.yaml"
      
      master.vm.provision :shell, :path => "master/provision.sh", :privileged => true
    end
  end
  


  (1..MINION_COUNT).each do |i|
    config.vm.define vm_minion_name = "minion-%d" % i do |minion|

      minion.vm.box = "coreos-%s" % UPDATE_CHANNEL
      minion.vm.box_url = "http://#{UPDATE_CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_vagrant.json"

      minion.vm.hostname = vm_minion_name
      minion.vm.network :private_network, ip: minionIP(i)

      minion.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end

      minion.vm.provision :file, :source => "./minion/cloud-config.yml", :destination => "/tmp/vagrantfile-user-data"
      minion.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
      
      minion.vm.provision :file, :source => "./minion/kubelet.service", :destination => "/tmp/kubelet.service"
      minion.vm.provision :file, :source => "./minion/kube-proxy.manifest.yaml", :destination => "/tmp/kube-proxy.manifest.yaml"
      minion.vm.provision :file, :source => "./minion/worker-kubeconfig.yaml", :destination => "/tmp/worker-kubeconfig.yaml"
      minion.vm.provision :shell, :path => "minion/provision.sh", :privileged => true

    end
  end

  if CONFIG_KUBELET
    system "kubectl config set-cluster next-gen-cluster --server=http://#{PROXY_IP}:8080 --insecure-skip-tls-verify=true"
    system "kubectl config set-context next-gen-context --cluster=next-gen-cluster --namespace=default"
    system "kubectl config use-context next-gen-context"
  end



end
