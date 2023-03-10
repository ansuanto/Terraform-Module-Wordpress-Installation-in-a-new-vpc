#!/bin/bash
yum install mariadb-server -y
systemctl start mariadb.service
systemctl enable mariadb.service
mysql -e "UPDATE mysql.user SET Password=PASSWORD('${ROOT_PASSWORD}') WHERE User='root';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
mysql -e "FLUSH PRIVILEGES;"
mysql -u root -p${ROOT_PASSWORD} -e "create database ${DATABASE_NAME};"
mysql -u root -p${ROOT_PASSWORD} -e "create user '${DATABASE_USER}'@'${DATABASE_HOST}' identified by '${DATABASE_PASSWORD}';"
mysql -u root -p${ROOT_PASSWORD} -e "grant all privileges on ${DATABASE_NAME}.* to '${DATABASE_USER}'@'${DATABASE_HOST}';"
mysql -u root -p${ROOT_PASSWORD} -e "flush privileges;"

systemctl restart mariadb.service
