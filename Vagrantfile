# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/precise32"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 64738, host: 64738 # Murmur
end
