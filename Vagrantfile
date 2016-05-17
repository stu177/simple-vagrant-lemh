# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
vmBox = "ubuntu/trusty64"

Vagrant.configure("2") do |config|

    # All Vagrant configuration is done here. The most common configuration
    # options are documented and commented below. For a complete reference,
    # please see the online documentation at vagrantup.com.

    # Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = vmBox

    # Hostname
    config.vm.hostname = 'app.dev'

    # Networking
    config.vm.network :private_network, ip: "192.168.70.10"

    # Port forwarding
    config.vm.network "forwarded_port", guest: 80, host: 8070
    config.vm.network "forwarded_port", guest: 3306, host: 33067

    # Sync between the web root of the VM and the 'sites' directory
    config.vm.synced_folder ".", "/home/vagrant/yourproject", id: "vagrant-root",
        owner: "vagrant",
        group: "www-data",
        mount_options: ["dmode=775,fmode=664"]

    config.vm.provision "shell", path: "provision.sh"

end
