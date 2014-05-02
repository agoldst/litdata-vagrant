Running R Shiny and RStudio Server in a Virtual Box
===================================================
dieter.menne@menne-biomed.de

This is an extended and code-rewritten version of: 

https://github.com/leondutoit/shiny-server-on-ubuntu


Why
---

The Shiny server (http://shiny.rstudio.com) and the RStudio IDE server (http://rstudio.com) only run in Linux systems. If you are working in Windows, you have to connect to an external Linux server, or configure a virtual system.
With vagrant (http://www.vagrantup.com/), the installation and configuration of a virtual system can be automated; all required files are downloaded from the Internet using the Puppet (http://puppetlabs.com/) configuration system.

A vagrant-package does not contain the virtual machine and the installation, but rather the rules to construct one. Therefore, it is a small download, about 1MB zipped.

All feature described here have only been tested with Windows as the host operating system.

Installation Instructions
------------

All commands starting with _vagrant_ should be given on the command line (i.e. the _black box_ in Windows).  If the command `vagrant` fails, please add the path to the directory with `vagrant.exe` to the  PATH environment variable.

This installation has been tested with Oracle VirtualBox, version 4.3.10 on a Windows 7/64 host; and Vagrant 1.5.4.

There is a major issue with synced folders in Virtual Box 4.3.10.
See  [here](http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest) and [here](https://github.com/mitchellh/vagrant/issues/3341) and check the special code at the top of `puppet/manifests/rstudio-shiny-server.pp` if you are using some other version of Virtual Box-


* Install [Oracle Virtual Box](https://www.virtualbox.org/wiki/downloads)
* Install [Vagrant](http://www.vagrantup.com/downloads.html); best install it into folder `D:\vagrant` or `C:\vagrant` to avoid the `HashiCorp`-super-folder. 
* Install Virtual Box Guest Additions: `vagrant plugin install vagrant-vbguest`; this step is tricky, please consult [vbguest]{https://github.com/dotless-de/vagrant-vbguest} in case of errors. If this step fails, you get an error `Failed to mount folders in Linux guests` later.  Google and Stack Overflow are full of messages on `virtual box guest additions`.
* If you have `git` installed, clone the project: `git clone git@bitbucket.org:dmenne/rstudio-shiny-server-on-ubuntu.git`
* If you do not have git installed, [download the zip file] (https://bitbucket.org/dmenne/rstudio-shiny-server-on-ubuntu/downloads/rstudio-shiny-server-on-ubuntu.zip) and unzip it into the vagrant directory.
* Navigate to the repository folder locally, e.g `cd \vagrant\rstudio-shiny-server-on-ubuntu`
* Run: `vagrant up` from the command line in this directory; this will need some time on the first start, because all packages are downloaded. Come back after an hour or a night.
* If you see error messages, try again: `vagrant reload` and/or `vagrant provision` 
* When in doubt run: `vagrant destroy` followed by  `vagrant up`.
* To connect to the Ubuntu system, use `vagrant ssh`;no password required. This is an insecure connection, intended to be used on a local machine only.
* To re-run the installation of the R-related components, use `vagrant provision`
* For more detailed debugging information, uncomment the line  `#:options => ["--verbose", "--debug"] do |puppet|` 
in file `Vagrantfile` by removing the `#`and prepending a `# to `:options => [] do |puppet|``.
* The important information controlling the installation is in file `Vagrantfile`, `usefulpackages.R`, and `puppet/manifests/rstudio-shiny-server.pp`.
* If you want to map additional directories to your Windows host, add lines following the pattern `config.vm.synced_folder  "etc", "/etc/shiny-server", create:true` to `Vagrantfile`, and do a `vagrant reload`.
* If you want additional R-packages installed, add these to the list in `usefulpackages.R`; do not forget to make a copy of the changes, this file will be overridden when you update to a more recent version of  `rstudio-shiny-server-on-ubuntu`.
* Check the top lines in `puppet/manifests/rstudio-shiny-server.pp`
* The default installation gives 2048MB memory to the VM. This might be too much, so check the line `v.memory = 2048` in `Vagrantfile`
* It is not necessary to keept the "black box" open to run the servers.
* If everything works ok once, you can also start and stop the 
VM system in your Oracle VM Virtual Box manager; use `rstudio-shiny-server-on-ubuntu_default`

Running Shiny 
-------------

* In your browser, use localhost:3838 to connect to the shiny servers. To edit your shiny project, use the mapped folder in `vagrant\rstudio-shiny-server-on-ubuntu\srv`; you do not have to do any work in the Ubuntu-box.

Running RStudio
-------------

* In your browser, use localhost:8787 to connect to the RStudio.  The user name is `shiny` and the password is `shiny`. Your home directory map to `vagrant\rstudio-shiny-server-on-ubuntu\srv` in the host operating system (assumed Windows).



- A tutorial to get to know [Vagrant](http://docs.vagrantup.com/v1/docs/getting-started/index.html)
- For a reference visit [Puppet](https://puppetlabs.com/)

