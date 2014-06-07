include wget
# Installs RStudio (user shiny, password shiny) and Shiny
# Change these if the version changes
# See http://www.rstudio.com/ide/download/server
# This is the standard installation (update it when a new release comes out)
# $rstudioserver = 'rstudio-server-0.98.507-amd64.deb'
# $getrstudio = "wget -nc http://download2.rstudio.org/${rstudioserver}"

# A more recent daily build
$rstudioserver = 'rstudio-server-0.98.907-amd64.deb'
$getrstudio = "wget -nc https://s3.amazonaws.com/rstudio-dailybuilds/${rstudioserver}"

# See http://www.rstudio.com/shiny/server/install-opensource
$shinyserver = 'shiny-server-1.1.0.10000-amd64.deb'
$getshiny = "wget -nc http://download3.rstudio.org/ubuntu-12.04/x86_64/${shinyserver}"


# Update system for r install
class update_system {   
    exec {'apt_update':
        provider => shell,
        command  => 'apt-get update;',
    }
    ->
    package {['software-properties-common','libapparmor1',
              'python-software-properties', 
              'upstart','dbus-x11', # required for init-checkconf
              'haskell-platform',
              'python', 'g++', 'make','vim', 'whois','mc','libcairo2-dev',
              'default-jdk', 'gdebi-core', 'libcurl4-gnutls-dev']:
      ensure  => present,
    }
    ->
    exec {'add-cran-repository':
      provider => shell,
      command  =>
      'add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu precise/";
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9;
      apt-get update;',
    }
    -> 
    exec {'upgrade-system':
      provider => shell,
      command  =>'apt-get -y upgrade',
    }
    ->
    # Install host additions (following https://www.virtualbox.org/manual/ch04.html
    # this must be done after upgrading.
    package {'dkms':
        ensure => present,
    }    
    ->
    exec { "update-cabal":
      command => "/usr/bin/cabal update",
      unless => "/usr/bin/test -f /root/.cabal/packages/hackage.haskell.org/00-index.tar.gz";
    }
    -> # We need a more recent version of pandoc
    exec {'update-haskell':
      provider =>shell,
      command =>'cabal update',
      unless => "test -f /root/.cabal/packages/hackage.haskell.org/00-index.tar.gz";
    }
    ->
    exec {'install-pandoc': 
      provider =>shell,
      timeout => 1800,
      command =>'cabal install --global pandoc pandoc-citeproc',
      unless => "test -f /root/.cabal/packages/hackage.haskell.org/pandoc"
    }
}


# Install r base and packages
class install_r {
    package {['r-base', 'r-base-dev']:
      ensure  => present,
      require => Package['dkms'],
    }    
    ->
    exec {'install-r-packages':
        provider => shell,
        timeout  => 1200,
        command  => 'Rscript /vagrant/usefulpackages.R'
    }
}

# Download and install shiny server and add users
class install_shiny_server {

    # Download shiny server
    exec {'shiny-server-download':
        provider => shell,
        require  => [Exec['install-r-packages'],
                    Package['software-properties-common',
                    'python-software-properties', 'g++']],
        command  => $getshiny,
        unless => "test -f ${shinyserver}",
    }
    ->
    # http://www.pindi.us/blog/getting-started-puppet
    user {'shiny':
        ensure  => present,
        groups   => ['rstudio_users', 'vagrant'], # adding to vagrant required for startup
        shell   => '/bin/bash',
        managehome => true,
        name    => 'shiny',
        home    => '/srv/shiny-server',
    }   
    ->    
    # Create rstudio_users group
    group {'rstudio_users':
        ensure => present,
    }
    ->
    # Install shiny server
    exec {'shiny-server-install':
        provider => shell,
        command  => "gdebi -n ${shinyserver}",
    }
    ->
    # Copy example shiny files
    file {'/srv/shiny-server/01_hello':
        source  => '/usr/local/lib/R/site-library/shiny/examples/01_hello',
        owner   => 'shiny',
        ensure  => 'directory',
        recurse => true,
    }   
    ->
   # Setting password during user creation does not work    
   # Password shiny is public; this is for local use only
   exec {'shinypassword':
        provider => shell,
        command => 'usermod -p `mkpasswd -H md5 shiny` shiny',
     }
    ->
    # Remove standard app
    file {'/srv/shiny-server/index.html':
        ensure => absent,
    } 
}

# install rstudio and start service
class install_rstudio_server {
    # Download rstudio server
    exec {'rstudio-server-download':
        require  => Package['r-base'],
        provider => shell,
        command  => $getrstudio,
        unless => "test -f ${rstudioserver}",
    }
    ->
    exec {'rstudio-server-install':
        provider => shell,
        command  => "gdebi -n ${rstudioserver}",
    }
}

# Make sure that both services are running
class check_services{
    service {'shiny-server':
        ensure    => running,
        require   => User['shiny'],
        hasstatus => true,
    }
    service {'rstudio-server':
        ensure    => running,
        require   => Exec['rstudio-server-install'],
        hasstatus => true,
    }
}

class startupscript{
    file { '/etc/init/makeshinylinks.sh':
       require   => Service['shiny-server'],
       ensure => 'link',
       target => '/vagrant/makeshinylinks.sh',
    }
 ->
    exec{ 'reboot-makeshiny-links':
       provider  => shell,
       command   => '/vagrant/makeshinylinks.sh',
    }  
}



include update_system
include install_r
include install_shiny_server
include install_shiny_server
include install_rstudio_server
include check_services
include startupscript

