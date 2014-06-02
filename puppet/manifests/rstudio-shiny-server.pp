include wget

# Change these if the version changes
# See http://www.rstudio.com/ide/download/server
$rstudioserver = 'rstudio-server-0.98.507-amd64.deb'
$getrstudio = "wget -nc http://download2.rstudio.org/${rstudioserver}"

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
              'haskell-platform',
              'python-software-properties', 
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
    exec {'update-haskell':
      provider =>shell,
      command =>'cabal update',
    }
    ->
    exec {'install-pandoc': 
      provider =>shell,
      command =>'cabal install pandoc pandoc-citeproc',
      timeout     => 1800,
    }
    ->
    exec {'addpandoctopath':
      provider =>shell,
      command => 'ln -s $HOME/.cabal/bin/* /usr/local/bin',
    }
    
    ->
    # Install host additions (following https://www.virtualbox.org/manual/ch04.html
    # this must be done after upgrading.
    package {'dkms':
        ensure => present,
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
        command  => $getshiny
    }
    ->
    # Install shiny server
    exec {'shiny-server-install':
        provider => shell,
        command  => "gdebi -n ${shinyserver}",
    }

    ->    
    # Create rstudio_users group
    group {'rstudio_users':
        ensure => present,
    }
    ->
  # http://www.pindi.us/blog/getting-started-puppet
    user {'shiny':
        ensure  => present,
        groups   => ['rstudio_users'],
        shell   => '/bin/bash',
        managehome => true,
        name    => 'shiny',
        home    => '/srv/shiny-server',
    }   
    ->
    # Copy example shiny files
    file {'/srv/shiny-server':
        source  => '/usr/local/lib/R/site-library/shiny/examples',
        owner   => 'shiny',
        ensure  => 'directory',
        recurse => true,
    }   
    ->
   # Setting password during user creation does not work    
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
        command  => $getrstudio
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
        require   => Exec['shiny-server-install'],
        hasstatus => true,
    }
    service {'rstudio-server':
        ensure    => running,
        require   => Exec['rstudio-server-install'],
        hasstatus => true,
    }
}

include update_system
include install_r
include install_shiny_server
include install_shiny_server
include install_rstudio_server
include check_services

