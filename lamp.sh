#!/bin/bash
echo "#######################"
echo "Installing httpd"
echo "#######################"
yum install -y httpd

echo "Starting httpd"
systemctl start httpd.service

echo "Adding firewall rules"
firewall-cmd --add-port 80/tcp --permanent
firewall-cmd --add-port 443/tcp --permanent

echo "Reload firewall"
firewall-cmd --reload
echo "#######################################"
echo "End of apache http server installation"
echo "#######################################"
echo " "
echo "#######################"
echo "Installing PHP"
echo "#######################"
yum install -y php php-mysql

echo "Restarting httpd"
systemctl restart httpd.service

echo "Testing the PHP on the web server"
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

echo "End of PHP installation"

echo "#######################"
echo "Installing MariaDB"
echo "#######################"
yum install -y mariadb-server mariadb

echo "Starting MariaDB"
systemctl start mariadb

echo "securing installation"
mysql_secure_installation << EOF

Y
root
root
Y
Y
Y
Y
EOF

echo "Enable MariaDB"
systemctl enable mariadb.service
echo "#############################"
echo "End of MariaDB Installation"
echo "#############################"

echo "WORDPRESS Installation in LAMP"
echo "Creating wordpress database"
mysql -u root --password=root << EOF
CREATE DATABASE wordpress;
echo "Creating user and password"
CREATE USER wordpressuser@localhost IDENTIFIED BY '12345';
echo "grant user's privileges"
GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY '12345';
FLUSH PRIVILEGES;
EOF

echo "#############################"
echo "wordpress database created"
echo "#############################"
echo " "
echo "#############################"
echo "Install php for wordpress"
echo "#############################"
yum install -y php-gd

echo "restarting httpd"
systemctl restart httpd

echo "download wordpress through url"
cd /opt/
yum install -y wget
wget http://wordpress.org/latest.tar.gz

echo "extracting wordpress file"
tar xzvf latest.tar.gz

echo "copying wordpress files to apache directory"
rsync -avP wordpress/ /var/www/html/
echo "creating folder to store uploaded files"
mkdir /var/www/html/wp-content/uploads
echo "changing permission for wordpress files"
chown -R apache:apache /var/www/html/*
echo "Configuring wordpress"
cd /var/www/html/
echo "wp-config file copied"
cp wp-config-sample.php wp-config.php








