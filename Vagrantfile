# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.provision "shell", inline: <<-SHELL
    sudo /bin/bash /vagrant/install-atlascine.sh
  SHELL
end
