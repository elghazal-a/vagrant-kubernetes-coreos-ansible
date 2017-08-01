# -*- mode: ruby -*-
# vi: set ft=ruby :

UPDATE_CHANNEL = "stable"
COREOS_VERSION = "1409.7.0"
MASTER_COUNT = 1
MINION_COUNT = (ENV['MINION_COUNT'] || 1).to_i

CONFIG_KUBELET  = ENV['CONFIG_KUBELET'] || false

COREOS_HOST_NAMES = []
MASTER_IP = "172.17.4.100"
def minionIP(num)
  return "172.17.4.#{num+200}"
end

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end


    config.vm.define vm_master_name = "master" do |master|
      COREOS_HOST_NAMES.push(vm_master_name)

      master.vm.box = "coreos-%s" % UPDATE_CHANNEL
      master.vm.box_url = "http://#{UPDATE_CHANNEL}.release.core-os.net/amd64-usr/#{COREOS_VERSION}/coreos_production_vagrant.json"
    
      master.vm.hostname = vm_master_name
      master.vm.network :private_network, ip: MASTER_IP

      master.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
      end

      master.vm.provision :ansible do |ansible|
        ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}"
        ansible.galaxy_role_file = "./requirements.yml"
        ansible.galaxy_roles_path = "./roles"
        ansible.playbook = "./master.pb.yml"
        ansible.groups = {
          "coreos" => COREOS_HOST_NAMES,
          "coreos:vars" => {"ansible_python_interpreter" => "/home/core/bin/python"
                           }
        }
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
          api_ip: MASTER_IP
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
    system "kubectl config set-cluster vagrant-cluster --server=http://#{MASTER_IP}:8080 --insecure-skip-tls-verify=true"
    system "kubectl config set-context vagrant-context --cluster=vagrant-cluster --namespace=default"
    system "kubectl config use-context vagrant-context"
  end



end
