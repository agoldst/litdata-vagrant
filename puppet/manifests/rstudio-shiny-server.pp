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

    package {['software-properties-common',
              'python-software-properties', 
              'python', 'g++', 'make','vim', 'whois']:
      ensure  => present,
      require => Exec['apt_update'],
    }

    package{'default-jdk':
        ensure => present,
    }

    # Install gdebi
    package{'gdebi-core':
        ensure => present,
    }

    # for RCurl
    package{'libcurl4-gnutls-dev':
        ensure => present,
    }

    exec {'add-cran-repository':
      require  => Package['python-software-properties'],
      provider => shell,
      command  =>
      'add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu precise/";
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9;
      apt-get update;',
    }
    exec {'upgrade-system':
      require  => Exec['add-cran-repository'],
      provider => shell,
      command  =>'apt-get -y upgrade',
    }

    # Install host additions (following https://www.virtualbox.org/manual/ch04.html
    # this must be done after upgrading.
    package {'dkms':
        ensure => present,
        require =>Exec['upgrade-system'],
    }
}

# Install r base and packages
class install_r {
    package {'r-base':
      ensure  => present,
      require => [Package['dkms','default-jdk','gdebi-core','libcurl4-gnutls-dev']],
    }
    package {'r-base-dev':
      ensure  => present,
      require => Exec['add-cran-repository'],
    }

    exec {'install-r-packages':
        provider => shell,
        require  => Package['r-base'],
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

    # Install shiny server
    exec {'shiny-server-install':
        provider => shell,
        require  => [Package['gdebi-core'], Exec['shiny-server-download']],
        command  => "gdebi -n ${shinyserver}",
    }


    # Copy example shiny files
    file {'/srv/shiny-server':
        source  => '/usr/local/lib/R/site-library/shiny/examples',
        owner   => 'shiny',
        ensure  => 'directory',
        require => Exec['shiny-server-install'],
        recurse => true,
    }

    # Remove standard app
    file {'/srv/shiny-server/index.html':
        require => File['/srv/shiny-server'],
        ensure => absent,
    } 

    # Create rstudio_users group
    group {'rstudio_users':
        ensure => present,
        require => File['/srv/shiny-server'],
    }

  # http://www.pindi.us/blog/getting-started-puppet
    user {'shiny':
        ensure  => present,
        require => [Exec['shiny-server-install'],File['/srv/shiny-server'],
                    Group['rstudio_users']],
        groups   => ['rstudio_users'],
        shell   => '/bin/bash',
        managehome => true,
        name    => 'shiny',
        home    => '/srv/shiny-server',
    }   
   # Setting password during user creation does not work    
   exec {'shinypassword':
        require => User['shiny'],
        provider => shell,
        command => 'usermod -p `mkpasswd -H md5 shiny` shiny',
     }
}

# install rstudio and start service
class install_rstudio_server {
    package {'libapparmor1':
        ensure  => present,
        require => Package['r-base'],
    }
    # Download rstudio server
    exec {'rstudio-server-download':
        provider => shell,
        require  => Package['libapparmor1'],
        command  => $getrstudio
    }

    exec {'rstudio-server-install':
        provider => shell,
        require  => [Package['gdebi-core'], Exec['rstudio-server-download']],
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

