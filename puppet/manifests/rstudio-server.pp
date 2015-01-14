include wget

$rstudioserver = 'rstudio-server-0.98.1091-amd64.deb'
$urlrstudio = 'http://download2.rstudio.org/'

# Update system for r install
class update_system {   
    exec { 'apt_update':
        provider => shell,
        command  => 'apt-get update;',
    }
    ->
    package { [
        'software-properties-common','libapparmor1',
        'libdbd-mysql', 'libmysqlclient-dev','libssl-dev',
        'python-software-properties',
        'upstart', 'psmisc',
        'python', 'g++', 'make','vim', 'whois','mc','libcairo2-dev',
        'default-jdk', 'gdebi-core', 'libcurl4-gnutls-dev' ]:
        ensure  => present,
    }
    ->
    exec { 'add-cran-repository':
      provider => shell,
      command  =>
'add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/";
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9;
apt-get update;',
    }
    -> 
    exec { 'upgrade-system':
        provider => shell,
        timeout => 2000, # On slow machines, this needs some time
        command  =>'apt-get -y upgrade;apt-get -y autoremove;',
    }
    ->
    # Install host additions
    # (following https://www.virtualbox.org/manual/ch04.html
    # this must be done after upgrading.
    package { 'dkms':
        ensure => present,
    }    
}

# Install r base and packages
class install_r {
    package { ['r-base', 'r-base-dev']:
      ensure  => present,
      require => Package['dkms'],
    }    
    ->
    exec {'install-r-packages':
        provider => shell,
        timeout  => 3000,
        command  => 'Rscript /vagrant/r-packages.R'
    }
}

# install rstudio and start service
class install_rstudio_server {
    # Download rstudio server
    wget::fetch {'rstudio-server-download':
        require  => Package['r-base'],
        timeout  => 0,
        destination => "${rstudioserver}",
        source  => "${urlrstudio}${rstudioserver}",
    }
    ->
    exec {'rstudio-server-install':
        provider => shell,
        command  => "gdebi -n ${rstudioserver}",
    }
    ->    
    # Create rstudio_users group
    group {'rstudio_users':
        ensure => present,
    }
    ->
    # http://www.pindi.us/blog/getting-started-puppet
    user { 'litdata':
        ensure  => present,
        # adding to vagrant required for startup
        groups   => ['rstudio_users', 'vagrant'],
        shell   => '/bin/bash',
        managehome => true,
        name    => 'litdata',
        home    => '/home/litdata',
    }   
    ->
   # Setting password during user creation does not work    
   # Password shiny is public; this is for local use only
   exec { 'serverpass':
        provider => shell,
        command => 'usermod -p `mkpasswd -H md5 litdata` litdata',
     }
}

# Make sure that both services are running
class check_services {
    service {'rstudio-server':
        ensure    => running,
        require   => [User['litdata'], Exec['rstudio-server-install']],
        hasstatus => true,
    }
}



include update_system
include install_r
include install_rstudio_server
include check_services

