#!/usr/bin/env bash

PASSWORD='password'
PROJECT='yourproject'

# Webroot relative to project folder, i.e. ./ for /home/vagrant or ./public for /home/vagrant/public
WEBROOT='./public_html'

# Create project folder
sudo mkdir "/home/vagrant/${PROJECT}"

# Install apt-fast
sudo add-apt-repository ppa:saiarcot895/myppa
sudo apt-get update
sudo apt-get install -y apt-fast

# Update / upgrade
sudo apt-get update
sudo apt-fast -y upgrade

# Apache 2.5 and PHP 5.5
sudo apt-fast install -y apache2
sudo apt-fast install -y php5

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

# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/home/vagrant/${PROJECT}/${WEBROOT}"
    <Directory "/home/vagrant/${PROJECT}/${WEBROOT}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# Enable mod_rewrite
sudo a2enmod rewrite

# Restart Apache
sudo service apache2 restart

# Git
sudo apt-fast install -y git

# Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer