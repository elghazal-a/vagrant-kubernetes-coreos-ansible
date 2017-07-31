# -*- mode: ruby -*-
# vi: set ft=ruby :

UPDATE_CHANNEL = "stable"
COREOS_VERSION = "1409.7.0"
MASTER_COUNT = (ENV['MASTER_COUNT'] || 1).to_i
MINION_COUNT = (ENV['MINION_COUNT'] || 1).to_i
COREOS_HOST_NAMES = []
MASTERS_IPS = []

CONFIG_KUBELET  = ENV['CONFIG_KUBELET'] || false

PROXY_IP = "172.17.4.100"

def masterIP(num)
  return "172.17.4.#{num+100}"
end

def minionIP(num)
  return "172.17.4.#{num+200}"
end
ETCD_IPS = [*1..MASTER_COUNT].map{ |i| masterIP(i) }
INITIAL_ETCD_CLUSTER = ETCD_IPS.map.with_index{ |ip, i| "etcd#{i+1}=http://#{ip}:2380" }.join(",")

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
    
    for counter in 1..MASTER_COUNT
      MASTERS_IPS.push(masterIP(counter))
    end
    proxy.vm.provision :ansible do |ansible|
      ansible.limit = "proxy"
      ansible.playbook = "./proxy.pb.yml"
      ansible.extra_vars = {
        master_ips: MASTERS_IPS
      }
    end
  end

  (1..MASTER_COUNT).each do |i|
    config.vm.define vm_master_name = "master-%d" % i do |master|
      COREOS_HOST_NAMES.push(vm_master_name)

      master.vm.box = "coreos-%s" % UPDATE_CHANNEL
      master.vm.box_url = "http://#{UPDATE_CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_vagrant.json"
    
      master.vm.hostname = vm_master_name
      master.vm.network :private_network, ip: masterIP(i)

      master.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end

      master.vm.provision :ansible do |ansible|
        ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}"
        ansible.galaxy_role_file = "./requirements.yml"
        ansible.galaxy_roles_path = "./roles"
        ansible.limit = vm_master_name
        ansible.playbook = "./master.pb.yml"
        ansible.extra_vars = {
          etcdIndex: i,
          initial_etcd_cluster: INITIAL_ETCD_CLUSTER,
        }
        ansible.groups = {
          "coreos" => COREOS_HOST_NAMES,
          "coreos:vars" => {"ansible_python_interpreter" => "/home/core/bin/python"
                           }
        }
      end

    end
  end
  


  (1..MINION_COUNT).each do |i|
    config.vm.define vm_minion_name = "minion-%d" % i do |minion|
      COREOS_HOST_NAMES.push(vm_minion_name)

      minion.vm.box = "coreos-%s" % UPDATE_CHANNEL
      minion.vm.box_url = "http://#{UPDATE_CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_vagrant.json"

      minion.vm.hostname = vm_minion_name
      minion.vm.network :private_network, ip: minionIP(i)

      minion.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end

      minion.vm.provision :ansible do |ansible|
        ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}"
        ansible.galaxy_role_file = "./requirements.yml"
        ansible.galaxy_roles_path = "./roles"
        ansible.limit = vm_minion_name
        ansible.playbook = "./minion.pb.yml"
        ansible.extra_vars = {
          api_ip: PROXY_IP
        }
        ansible.groups = {
          "coreos" => COREOS_HOST_NAMES,
          "coreos:vars" => {"ansible_python_interpreter" => "/home/core/bin/python"
                           }
        }
      end

    end
  end

  if CONFIG_KUBELET
    system "kubectl config set-cluster vagrant-cluster --server=http://#{PROXY_IP}:8080 --insecure-skip-tls-verify=true"
    system "kubectl config set-context vagrant-context --cluster=vagrant-cluster --namespace=default"
    system "kubectl config use-context vagrant-context"
  end



end
