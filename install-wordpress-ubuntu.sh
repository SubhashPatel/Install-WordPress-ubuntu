#!/bin/bash

#######################################
# Bash script to install WordPress on ubuntu
# Author: Subhash (serverkaka.com)

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Ask value for mysql root password 
read -p 'wordpress_db_name [wp_db]: ' wordpress_db_name
read -p 'db_root_password [secretpasswd]: ' db_root_password
echo

# Update system
sudo apt-get update -y

## Install APache
sudo apt-get install apache2 apache2-utils -y
sudo systemctl start apache2
sudo systemctl enable apache2

## Install PHP
sudo apt-get install php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-cli php7.0-cgi php7.0-gd -y

# Install MySQL database server
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"
apt-get install mysql-server mysql-client -y

## Install Latest WordPress
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
sudo rsync -av wordpress/* /var/www/html/

# Set Permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

## Configure WordPress Database
mysql -uroot -p$db_root_password <<QUERY_INPUT
CREATE DATABASE $wordpress_db_name;
GRANT ALL PRIVILEGES ON $wordpress_db_name.* TO 'root'@'localhost' IDENTIFIED BY '$db_root_password';
FLUSH PRIVILEGES;
EXIT
QUERY_INPUT

# Enabling Mod Rewrite
sudo a2enmod rewrite
sudo php5enmod mcrypt

## Install PhpMyAdmin
sudo apt-get install phpmyadmin -y

## Configure PhpMyAdmin
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf

# Restart Apache
sudo service apache2 restart
