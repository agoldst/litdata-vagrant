# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# There is a major issue with synced folders in Virtual Box 4.3.10.
# DO NOT USE THIS version
# http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest
# https://github.com/mitchellh/vagrant/issues/3341

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Set up the box
    config.vm.box = "ubuntu/trusty64"
    config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
    # To install from a local file uncomment the following after adjusting the path
    # Note the forward slashes used, even on Windows
    # config.vm.box_url =  "file:///D:/vagrant/rstudio-shiny-server-on-ubuntu/trusty/trusty64.box"
    
    # Port forwarding
    config.vm.network "forwarded_port", guest: 3838, host: 3838
    # RStudio
    config.vm.network "forwarded_port", guest: 8787, host: 8787
    # OpenCPU
    config.vm.network "forwarded_port", guest: 80, host: 8080

    config.vm.synced_folder  "etc/rstudio", "/etc/rstudio", create:true
    config.vm.synced_folder  "etc/shiny-server", "/etc/shiny-server", create:true
    config.vm.synced_folder  "shiny-server", "/srv/shiny-server", create:true
    # add dummy to avoid "Could not retrieve fact fqdn"
    config.vm.hostname = "vagrant.example.com"

   # Provisioning
    config.vm.provision :puppet,
#    :options => ["--verbose", "--debug"] do |puppet|
#    :options => ["--debug"] do |puppet|
     :options => [] do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = "rstudio-shiny-server.pp"
        puppet.module_path = "puppet/modules"

    end

end