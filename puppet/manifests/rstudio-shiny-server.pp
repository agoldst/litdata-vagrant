include wget
# Installs RStudio (user shiny, password shiny) and Shiny
# Change these if the version changes
# See http://www.rstudio.com/ide/download/server
# This is the standard installation (update it when a new release comes out)
# $rstudioserver = 'rstudio-server-0.98.507-amd64.deb'
# $urlrstudio = "http://download2.rstudio.org/"

# A more recent daily build
$rstudioserver = 'rstudio-server-0.98.919-amd64.deb'
$urlrstudio = 'https://s3.amazonaws.com/rstudio-dailybuilds/'

# See http://www.rstudio.com/shiny/server/install-opensource
$shinyserver = 'shiny-server-1.2.0.355-amd64.deb'
$urlshiny = 'https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/'

#$urlshiny = 'http://download3.rstudio.org/ubuntu-12.04/x86_64/'
#$shinyserver = 'shiny-server-1.1.0.10000-amd64.deb'

#http://projects.puppetlabs.com/projects/puppet/wiki/Simple_Text_Patterns/7
define line($file, $line, $ensure = 'present') {
    case $ensure {
        default : { err ( "unknown ensure value ${ensure}" ) }
        present: {
            exec { "/bin/echo '${line}' >> '${file}'":
                unless => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
        absent: {
            exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
                onlyif => "/bin/grep -qFx '${line}' '${file}'"
            }
        }
    }
}

# Update system for r install
class update_system {   
    exec {'apt_update':
        provider => shell,
        command  => 'apt-get update;',
    }
    ->
    package {['software-properties-common','libapparmor1',
              'python-software-properties', 
              'upstart',
              'dbus-x11', # required for init-checkconf
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
    wget::fetch {'shiny-server-download':
        require  => [Exec['install-r-packages'],
                    Package['software-properties-common',
                    'python-software-properties', 'g++']],
        destination => "${shinyserver}",
        timeout  => 300,
        source   => "${urlshiny}${shinyserver}",
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
        groups   => ['rstudio_users', 'vagrant'], # adding to vagrant required for startup
        shell   => '/bin/bash',
        managehome => true,
        name    => 'shiny',
        home    => '/srv/shiny-server',
    }   
    ->
    # Install shiny server
    exec {'shiny-server-install':
        provider => shell,
        command  => "gdebi -n ${shinyserver}",
    }
    -> # Make sure it's UTF-8 in shiny-server.conf (!!!! remove this later )
    exec {'makeutf':
      provider =>shell,
      command  => 'sed -i "s/\'C\'/\'en_US.UTF-8\'/" /etc/init/shiny-server.conf'
    }
    ->
   line { 'add-sleep':
    file => '/etc/init/shiny-server.conf',
    line => 'post-stop exec sleep 5',
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
}

# Make sure that both services are running
class check_services{
    service {'shiny-server':
        ensure    => running,
        require   => [User['shiny'], Exec['shiny-server-install']],
        hasstatus => true,
    }
    service {'rstudio-server':
        ensure    => running,
        require   => [User['shiny'], Exec['rstudio-server-install']],
        hasstatus => true,
    }
}

class startupscript{
    file { '/etc/init/makeshinylinks.conf':
       require   => Exec['shinypassword'],
       ensure => 'link',
       target => '/vagrant/makeshinylinks.conf',
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
include install_rstudio_server
include check_services
include startupscript

