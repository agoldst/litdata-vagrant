Running R Shiny and RStudio Server in a Virtual Box
===================================================
dieter.menne@menne-biomed.de

This is an extended and code-rewritten version of: 

https://github.com/leondutoit/shiny-server-on-ubuntu


Why
---

The Shiny server (http://shiny.rstudio.com) and the RStudio IDE server (http://rstudio.com) only run in Linux systems. If you are working in Windows (not tested, but might work: Apple), you have to connect to an external Linux server, or configure a virtual system.
With vagrant (http://www.vagrantup.com/), the installation and configuration of a virtual system can be automated; all required files are downloaded from the Internet using the Puppet (http://puppetlabs.com/) configuration system.

A vagrant-package does not contain the virtual machine and the installation, but rather the rules to construct one. Therefore, it is a small download.


Installation Instructions
------------

All commands starting with _vagrant_ should be given on the command line (i.e. the _black box_ in Windows).  If the command `vagrant` fails, please add the path to the directory with `vagrant.exe` to the  PATH environment variable.

This installation has been tested with Oracle VirtualBox, version 4.3.10 on a Windows 7/64 host; and Vagrant 1.5.4.

* Install Oracle Virtual Box from https://www.virtualbox.org/wiki/downloads  
* Install Vagrant: http://www.vagrantup.com/downloads.html; best install it into folder `D:\vagrant` or `C:\vagrant` to avoid the `HashiCorp`-superfolder. 
* Install Virtual Box Guest Additions: `vagrant plugin install vagrant-vbguest`
* Checkout this repository: `git clone `
* Navigate to the repository folder locally: `cd rstudio-shiny-server-on-ubuntu`
* Run: `vagrant up`
* If that did not work try: `vagrant reload` 
* When in doubt run: `vagrant destroy` followed by  `vagrant up`.
* To connect to the Ubuntu system, use `vagrant ssh`M`;no password required. This is an insecure connection,
intended to be used on a local machine only.
* To re-run the installation of the R-related components, use `vagrant provision`
* For more detailed debugging information, uncomment the line  `#:options => ["--verbose", "--debug"] do |puppet|` 
in file `Vagrantfile` by removing the `#`and prepending a `# to `:options => [] do |puppet|``.
* It is not necessary to keept the "black box" open to run the servers.
* If everything works ok once, you can also start and stop the 
VM system in your Oracle VM Virtual Box manager; use `rstudio-shiny-server-on-ubuntu_default`

Running Shiny 
-------------

In your browser use localhost:3838 to connect to the shiny servers


- tutorial to get to know [Vagrant](http://docs.vagrantup.com/v1/docs/getting-started/index.html)
- For a reference visit [Puppet](https://puppetlabs.com/)

