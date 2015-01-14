# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Set up the box
    config.vm.box = "ubuntu/trusty64"
    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      # v.cpus = 2
    end
    
    # Port forwarding
    # RStudio
    config.vm.network "forwarded_port", guest: 8787, host: 8787

    # add dummy to avoid "Could not retrieve fact fqdn"
    config.vm.hostname = "vagrant.example.com"

   # Provisioning
    config.vm.provision :puppet,
#    :options => ["--verbose", "--debug"] do |puppet|
#    :options => ["--debug"] do |puppet|
     :options => [] do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = "rstudio-server.pp"
        puppet.module_path = "puppet/modules"

    end

end
