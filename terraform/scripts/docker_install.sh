#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt-get update 
sudo apt-get install dialog apt-utils docker.io docker-compose smbclient cifs-utils -y

mkdir nextcloud 
#mkdir wordpress 
#mkdir zabbix

cat << EOF > nextcloud/docker-compose.yml
version: '2'
services:
  app:
    image: nextcloud
    restart: always
    ports:
      - 9000:80
    volumes:
      - ./nextcloud:/var/www/html
    environment:
      - REDIS_HOST=redis
  redis:
    image: redis:alpine
    container_name: redis
    volumes:
      - ./redis:/data
    restart: unless-stopped
EOF

#cat << EOF > zabbix/docker-compose.yml
#version: '3.7'
#volumes:
#  db:
#
#services:
#  mariadb:
#    image: mariadb:10.11
#    command: 
#      --transaction-isolation=READ-COMMITTED 
#      --log-bin=binlog --binlog-format=ROW
#      --log_bin_trust_function_creators=1
#      --character-set-server=utf8mb4 
#      --collation-server=utf8mb4_bin
#    restart: always
#    environment:
#      - MARIADB_RANDOM_ROOT_PASSWORD=true
#      - MARIADB_DATABASE=zabbix
#      - MARIADB_USER=adminuser
#      - MARIADB_PASSWORD=P@ssword2023
#    volumes:
#      - db:/var/lib/mysql
#
#  zabbix-server:
#    image: zabbix/zabbix-server-mysql:6.0-ubuntu-latest
#    restart: always
#    environment:
#      - MYSQL_DBNAME=zabbix
#      - MYSQL_USER=adminuser
#      - MYSQL_PASSWORD=P@ssword2023
#      - DB_SERVER_HOST=mariadb
#      - ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1
#  
#  zabbix-web:
#    image: zabbix/zabbix-web-nginx-mysql:6.0-ubuntu-latest
#    restart: always
#    depends_on: 
#      - zabbix-server
#    environment:
#      - ZBX_SERVER_HOST=zabbix-server
#      - MYSQL_DBNAME=zabbix
#      - MYSQL_USER=adminuser
#      - MYSQL_PASSWORD=P@ssword2023
#      - DB_SERVER_HOST=mariadb
#    ports:
#      - 9001:8080
#    logging:
#      driver: none
#EOF

#cat << EOF > wordpress/docker-compose.yml
#version: '2'
#services:
#  wordpress:
#    image: bitnami/wordpress
#    ports:
#      - 9002:8080
#    restart: always
#    environment:
#      - WORDPRESS_DATABASE_USER=adminuser
#      - WORDPRESS_DATABASE_NAME=wordpress
#      - WORDPRESS_DATABASE_PASSWORD=P@ssword2023
#      - WORDPRESS_DATABASE_HOST=db-edricus-ty.mariadb.database.azure.com
#EOF

(cd nextcloud ; docker-compose up -d)
#(cd zabbix ; docker-compose up -d)
#(cd wordpress ; docker-compose up -d)


