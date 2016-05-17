#!/usr/bin/env bash

PASSWORD='password'
PROJECT='yourproject'

# Webroot relative to synced folder, i.e. ./ for /home/vagrant or ./public for /home/vagrant/public
WEBROOT='./public_html'

# Create project folder
sudo mkdir "/home/vagrant/${PROJECT}"

# Install repos
sudo add-apt-repository ppa:saiarcot895/myppa

sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"

# Update
sudo apt-get update

# Install apt-fast
sudo apt-get install -y apt-fast

# Update / upgrade
sudo apt-get update
sudo apt-fast -y upgrade

# nginx
sudo apt-fast install -y nginx

# HHVM
sudo apt-fast install -y hhvm
sudo /usr/share/hhvm/install_fastcgi.sh
sudo service hhvm restart

# MySQL
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-fast install -y mysql-server
sudo apt-fast install -y php5-mysql

# Adminer
sudo mkdir /usr/share/adminer
sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
sudo ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
echo "Alias /adminer /usr/share/adminer/adminer.php" | sudo tee /etc/apache2/conf-available/adminer.conf
sudo a2enconf adminer.conf
sudo service apache2 restart

# Git
sudo apt-fast install -y git

# Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer