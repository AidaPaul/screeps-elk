# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/wily64"

  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "private_network", ip: "192.168.33.99"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    config.vm.synced_folder ".", "/opt/screeps-elk"
  end

  config.vm.provider "hyperv" do |hv|
    hv.memory = "2048"
    hv.cpus = "1"
    config.vm.box = "hashicorp/precise64"
    config.vm.synced_folder ".", "/opt/screeps-elk", type: "smb"
  end

  #config.vm.provision "ansible" do |ansible|
  #  ansible.playbook = "playbook.yml"
  #end

  config.vm.provision "shell", path: "installer.sh"
end
