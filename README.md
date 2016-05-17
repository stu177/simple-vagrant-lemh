# simple-vagrant-lemh

Core:

* Linux (Ubuntu 14.04.4 LTS)
* nginx 1.4.6
* MySQL 5.5
* HHVM 3

Other stuff included:

* Composer
* Git

The provision script also uses apt-fast to speed up the setup process.

## Usage:

Simply change the synced folder path in the Vagrantfile to the root of the folder you want shared with the VM and the path to the web root in the markdown.sh file.