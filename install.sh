#!/bin/bash
################################################################################
# Script for installing on Debian9 Attention not tested in ubuntu
# Author: Serge Mata co-pirate a tout le monde SMOMTools
#-------------------------------------------------------------------------------
# This script will install on Debian Stretch server.
# Debian de base installée DE BASE J'insiste.. Debian minimal.
#-------------------------------------------------------------------------------
#  Basculer en root en utilisant la commande su 
#  On doit se retrouver en root 
#  Creer un nouveau fichier 
#  nano setup.sh ou install.sh
#       Placez ce contenu dedans 
#       Execute the script to install
#  sh setup.sh ou install.sh
#  Sélectionner la version MySQL désirée. Jessie 5.6  pout php5
################################################################################

#Post install
#Debian 9
#-------------------------------------------------------------------------------
# Commun aux 2 versions
apt-get install build-essential -y
apt-get install apache2 apache2-dev -y
apt-get install git -y
# Postgres 
apt-get install postgresql -y
# nano /etc/postgresql/9.6/main/postgresql.conf
# listen_addresses = '*'
echo "     listen_addresses = '*'  " >> /etc/postgresql/9.6/main/postgresql.conf    
# nano /etc/postgresql/9.6/main/pg_hba.conf
# host    all             all             0.0.0.0/0            trust
# host    all             all            ::0/0                 trust
echo "host    all             all             0.0.0.0/0            trust " >> /etc/postgresql/9.6/main/pg_hba.conf     
echo "host    all             all            ::0/0                 trust " >> /etc/postgresql/9.6/main/pg_hba.conf    

systemctl restart postgresql
systemctl restart apache2

su postgres
# Partie 1 fin
# postgres@ Pas de script copier coller manuel
psql<<EOF 
CREATE USER evenement;
ALTER ROLE evenement WITH CREATEDB;
ALTER USER evenement WITH ENCRYPTED PASSWORD 'motdepasse' ;
ALTER USER evenement WITH SUPERUSER;
CREATE SCHEMA evenement;
CREATE DATABASE evenement;
GRANT ALL ON SCHEMA evenement TO evenement;
GRANT ALL ON ALL TABLES IN SCHEMA evenement TO evenement; 
EOF
exit
# Partie 2 fin
#Php7---------------------------------------------------------------------------
apt-get install libapache2-mod-php7.0 php7.0 php7.0-bcmath php7.0-bz2 php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-dba php7.0-dev php7.0-enchant php7.0-fpm php7.0-gd php7.0-gmp php7.0-imap php7.0-interbase php7.0-intl php7.0-json php7.0-ldap php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-odbc php7.0-opcache php7.0-pgsql php7.0-phpdbg php7.0-pspell php7.0-readline php7.0-recode php7.0-snmp php7.0-soap php7.0-sqlite3 php7.0-sybase php7.0-tidy php7.0-xml php7.0-xmlrpc php7.0-xsl php7.0-zip -y
# php ajustement
apt-get install php-apcu -y
cat /etc/php/7.0/cli/php.ini |grep -n 'memory_limit' 
# verifier 
# memory_limit = -1
cat /etc/php/7.0/cli/php.ini |grep -n 'date.timezone'
echo " date.timezone = Europe/Paris  " >> /etc/php/7.0/cli/php.ini
cat /etc/php/7.0/cli/php.ini |grep -n 'date.timezone'
# mcedit /etc/php/7.0/cli/php.ini
# decommenter ;date.timezone =  et mettre
# ligne +- 924
# date.timezone = Europe/Paris
cat /etc/php/7.0/apache2/php.ini |grep -n 'memory_limit ='
sed -i 's/memory_limit = 128M/memory_limit = -512M/g' /etc/php/7.0/apache2/php.ini
cat /etc/php/7.0/apache2/php.ini |grep -n 'memory_limit ='
#
# mcedit /etc/php/7.0/apache2/php.ini
# modifier la valeur
# ligne +- 389
# memory_limit = 512M
#Php5---------------------------------------------------------------------------
echo "Depot de jessie dans sources.list " 
mv /etc/apt/sources.list /etc/apt/sources.list.stretch
# mcedit /etc/apt/sources.list
# touch /etc/apt/sources.list
# echo "        deb http://ftp.debian.org/debian/ jessie main contrib non-free  " >> /etc/apt/sources.list
# echo "        deb-src http://ftp.debian.org/debian/ jessie main contrib non-free " >> /etc/apt/sources.list
# echo "        deb http://security.debian.org/ jessie/updates main contrib non-free " >> /etc/apt/sources.list
# echo "        deb-src http://security.debian.org/ jessie/updates main contrib non-free " >> /etc/apt/sources.list
# ou
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian/ jessie main contrib non-free
deb-src http://ftp.debian.org/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
EOF
cat /etc/apt/sources.list
#
apt-get update
apt-get upgrade 

echo "Installation du php 5 " 
apt-get install php5 php5-pgsql php5-gd php5-curl php5-cli 
apt-get install libapache2-mod-php5 php5-common php5-idn php-pear php5-imagick php5-imap php5-json php5-mcrypt php5-memcache php5-mhash php5-mysql php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl
#
cat /etc/php5/cli/php.ini |grep -n 'memory_limit' 
cat /etc/php5/cli/php.ini |grep -n 'date.timezone'
echo " date.timezone = Europe/Paris  " >> /etc/php5/cli/php.ini
cat /etc/php5/cli/php.ini |grep -n 'date.timezone'
cat /etc/php5/apache2/php.ini |grep -n 'memory_limit ='
sed -i 's/memory_limit = 128M/memory_limit = -512M/g' /etc/php5/apache2/php.ini
cat /etc/php5/apache2/php.ini |grep -n 'memory_limit ='
#-------------------------------------------------------------------------------
# Commun aux 2 versions
git clone https://github.com/betaglop/e-venement
# git clone https://github.com/e-venement/e-venement.git
cd e-venement
git submodule init
git submodule update
git submodule foreach --recursive git submodule update --init
# 
cd .. 
mv e-venement /var/www/html/e-venement
chmod -R 777 /var/www/html/e-venement
cp /var/www/html/e-venement/config/autoload.inc.php.template /var/www/html/e-venement/config/autoload.inc.php
cp /var/www/html/e-venement/config/databases.yml.template /var/www/html/e-venement/config/databases.yml
cp /var/www/html/e-venement/config/project.yml.template  /var/www/html/e-venement/config/project.yml

php /var/www/html/e-venement/lib/vendor/symfony/data/bin/check_configuration.php

cat /var/www/html/e-venement/config/databases.yml|grep -n 'v2' 
sed -i 's/v2/motdepasse/g' /var/www/html/e-venement/config/databases.yml

cat /var/www/html/e-venement/config/databases.yml|grep -n 'evenement'
sed -i 's/evenement/evenement/g' /var/www/html/e-venement/config/databases.yml

mcedit /var/www/html/e-venement/config/databases.yml
all:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn: 'pgsql:host=localhost;dbname=evenement'
      username: evenement
      password: motdepasse


cd /var/www/html/e-venement/

./symfony doctrine:build --all --application=default
# su postgres
# cat config/doctrine/functions-pgsql.sql | psql evenement
# exit
./symfony guard:create-user email@test.com evenement motdepasse
./symfony guard:promote evenement
./symfony cc
bin/check-missing-implementations.sh
#-------------------------------------------------------------------------------
echo "installation de phppgadmin"
apt-get install phppgadmin -y
sed -i 's/Require local/Require all granted/g' /etc/apache2/conf-enabled/phppgadmin.conf
# nano /etc/apache2/conf-enabled/phppgadmin.conf
# Only allow connections from localhost:
# Require local
# Require all granted
systemctl restart postgresql
systemctl restart apache2
#-------------------------------------------------------------------------------
# echo "Retour au sources stretch " 
# mv /etc/apt/sources.list /etc/apt/sources.list.jessie
# mv /etc/apt/sources.list.stretch /etc/apt/sources.list  
apt-get update
apt-get upgrade

mv /var/www/html/index.html /var/www/html/debapacheindex.html
mv /var/www/html/index.php /var/www/html/phpindex.php
touch /var/www/html/e-venement/index.php
touch /var/www/html/index.php
echo " <?php header('Location:http://192.168.192.135/e-venement/web');?> " >> /var/www/html/e-venement/index.php
echo " <?php header('Location:http://192.168.192.135/e-venement/web');?> " >> /var/www/html/index.php  




# no
# /etc/apache2/sites-available/000-default.conf
# DocumentRoot /var/www/html
# cat /etc/apache2/sites-available/000-default.conf |grep -n 'DocumentRoot /var/www/html'
# mcedit /etc/apache2/sites-available/000-default.conf
# DocumentRoot /var/www/html/e-venement/web
/etc/init.d/apache2 restart


./symfony doctrine:data-load --append data/fixtures/10-permissions.yml
./symfony doctrine:data-load --append data/fixtures/20-postalcodes.yml
./symfony doctrine:data-load --append data/fixtures/50-geo-fr-data.yml
./symfony doctrine:data-load --append data/fixtures/60-generic-data.yml 
./symfony doctrine:data-load --append data/fixtures/61-type-of-relationships.yml
