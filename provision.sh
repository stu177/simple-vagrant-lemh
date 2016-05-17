#!/usr/bin/env bash

PASSWORD='password'
PROJECT='yourproject'

# Webroot relative to synced folder, i.e. ./ for /home/vagrant or ./public for /home/vagrant/public
WEBROOT='./public_html'

# Find settings for nginx config
WORKER_PROCESSES=$(grep processor /proc/cpuinfo | wc -l)
WORKER_CONNECTIONS=$(ulimit -n)

# nginx configurations
GLOBAL_NGINX_CONF="
user  www-data www-data;
worker_processes  ${WORKER_PROCESSES};

events {
    worker_connections  ${WORKER_CONNECTIONS};
}

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    #tcp_nopush on;

    # Gzip configuration
    gzip on;
    gzip_disable 'msie6';
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css text/xml application/xml application/javascript application/x-javascript text/javascript;

    # Add my servers
    include /etc/nginx/sites-enabled/*;

    # Buffers
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;

    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;

    # Log off
    access_log off;
}
"

NGINX_CONF="
server {
    listen 80;

    root /home/vagrant/${PROJECT}/${WEBROOT};
    index index.html index.htm index.php;

    server_name localhost;
    client_max_body_size 32M;
    large_client_header_buffers 4 16k;

    location ~ \.(hh|php)$ {
        fastcgi_keep_conn on;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
        root /usr/share/nginx/html;
    }
}"

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

# Setup nginx
echo "${GLOBAL_NGINX_CONF}" > /etc/nginx/nginx.conf;
echo "${NGINX_CONF}" > /etc/nginx/sites-available/yourproject;
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/yourproject /etc/nginx/sites-enabled/yourproject
sudo service nginx restart

# MySQL
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-fast install -y mysql-server
sudo apt-fast install -y php5-mysql

# Git
sudo apt-fast install -y git

# Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer