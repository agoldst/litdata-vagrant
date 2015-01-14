This provides a self-contained virtual environment running R and RStudio. If you have difficulties installing R, TeX, or RStudio on your home machine, you should be able to use this setup instead. Also, if your program runs correctly in this environment, it will run correctly when I test it as well (since I have the very same environment). 

# Installation

Requirements: this is meant to run on almost any system. However, you will need a substantial amount of RAM (4 GB) and disk space (5 GB).

1. Install [Vagrant](https://www.vagrantup.com/downloads).
2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
3. Download [this repository as a zip archive](https://github.com/agoldst/litdata-vagrant/archive/master.zip) and unzip it. Note the folder you unzip it into.
4. Open a terminal (Windows calls this a "Command Window") and change to the folder from the last step. (Use the `cd` command.)
5. Enter the command: `vagrant box add ubuntu/trusty64` and press Return.
6. Enter the command: `vagrant up` and press Return. Now begins a long process of downloading and installing software. This will require a large amount of disk space and time to complete (on my machine, it took about 5GB and about an hour of downloading and installing). You will know it is finished when you get a new command prompt (and hopefully no error messages).


# Testing

1. Open your web browser and visit `http://localhost:8787`. You should see an RStudio login screen. Enter username `vagrant` and password `vagrant` and log in. You should now see a three-paned RStudio window.
1. Type the following command into the left-side pane (the R console): `source("/vagrant/test/test.R")` and press Return. You should see a few messages, and then a final message reading `Looks okay.`
1. In RStudio's File menu, choose "Open." Enter the following path: `/vagrant/test/test.pdf`. A PDF file should open up in your web browser. It should look like [this file](http://www.rci.rutgers.edu/~ag978/litdata/vagrant-test.pdf).
1. Close the window. Click "Sign Out" on the upper right of the RStudio window.
1. Enter `vagrant halt` and press Return.
1. Check in the folder where you unzipped all these for a file called `test.pdf`. Open this file in Preview or Adobe Reader (it should be the same as before).

# Starting and stopping the virtual machine

Before you can use RStudio in the web server, you have to start the virtual machine. That is what `vagrant up` does. (It's much faster after the first time, because there's no new software to install.) Once you are done working, you will want to reclaim the (large) amount of RAM required to run all this software locally. That is the purpose of the command `vagrant halt`.

# Saving your work

When you are working in RStudio Server, your files live on the virtual machine's virtual hard drive. How do you get those files off the virtual machine and back to your regular hard drive so you can print them, e-mail them, back them up, etc.? The answer is that a special folder is *shared* between the virtual machine and your real hard drive. This is `/vagrant`. Any file you save there on the virtual machine will appear in the folder where you saved the `Vagrantfile`. The same process works in reverse.

You'll find it convenient to create a subfolder of this file and use *that* as your usual working directory.








This configuration is based on a repository by [Dieter Menne](https://bitbucket.org/dmenne/rstudio-shiny-server-on-ubuntu). I have also made use of work by [Lincoln Mullen](https://github.com/lmullen/vagrant-r-dev/).
