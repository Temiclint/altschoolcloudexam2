#!/bin/bash

sudo apt update
sudo apt upgrade -y


#LAMP STACK CONFIG
sudo apt install apache2 -y
sudo apt install mysql-server -y
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-json php>
sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini
sudo systemctl restart apache2


sudo apt install curl -y 
sudo curl -sS https://getcomposer.org/installer | php 
sudo mv composer.phar /usr/local/bin/composer 
composer --version < /dev/null

#clone from github
cd /var/www/html && git clone https://github.com/laravel/laravel.git
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
cd /var/www/html/laravel && cp .env.example .env

sudo mkdir /var/www/html/laravel && cd /var/www/html/laravel
cd /var/www/html && sudo git clone https://github.com/laravel/laravel.git
cd /var/www/html/laravel && composer install --no-dev < /dev/null
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache
cd /var/www/html/laravel && sudo cp .env.example .env
php artisan key:generate

# Apache2 configuration
cat << EOF > /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
    ServerAdmin info@direadelaja.com
    ServerName 192.168.39.21
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
    Options Indexes MultiViews FollowSymLinks
    AllowOverride All
    Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2enmod rewrite
sudo a2ensite laravel.conf
sudo systemctl restart apache2

#clone from github
cd /var/www/html && git clone https://github.com/laravel/laravel.git
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
cd /var/www/html/laravel && cp .env.example .env

sudo mkdir /var/www/html/laravel && cd /var/www/html/laravel
cd /var/www/html && sudo git clone https://github.com/laravel/laravel.git
cd /var/www/html/laravel && composer install --no-dev < /dev/null
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/bootstrap/cache
cd /var/www/html/laravel && sudo cp .env.example .env
php artisan key:generate

# mysql configuration 

echo "Creating MySQL user and database"
PASS=$2
if [ -z "$2" ]; then
  PASS=`openssl rand -base64 8`
fi

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE $1;
CREATE USER '$1'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "sql User created"
echo "Username:   $1"
echo "Database:   $1"
echo "Password:   $PASS"


# keygen

sudo sed -i 's/DB_DATABASE=laravel/DB_DATABASE=teddi/' /var/www/html/laravel/.env
sudo sed -i 's/DB_USERNAME=root/DB_USERNAME=teddi/' /var/www/html/laravel/.env
sudo sed -i 's/DB_PASSWORD=/DB_PASSWORD=teddi90/' /var/www/html/laravel/.env
php artisan config:cache
cd /var/www/html/laravel && php artisan migrate

