#!/bin/bash

if [ $# -ne 1 ]
then
  echo "ERROR: Uso: $0 <CIUDADES_WD>"
fi

$CIUDADES_WD="$1"

echo "Se procede a crear base de datos y usuario de base de datos, por favor introduzca la contraseña del usuario root:"

mkdir "$CIUDADES_WD"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear carpeta $CIUDADES_WD"
  exit 1
fi

cd "$CIUDADES_WD"

git init
git pull https://github.com/sebasgoldberg/iamsoft_ciudades.git

DB_NAME='ciudades'
DB_USER='ciudades'
DB_PASS='ciudades1234'

(echo "create database $DB_NAME character set utf8;"
echo "create user '$DB_USER'@'localhost' identified by '$DB_PASS';"
echo "grant all on $DB_NAME.* to $DB_USER;"
) | mysql -u root -p

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear usuario $DB_USER y base de datos $DB_NAME."
  exit 1
fi

./manage.py syncdb
./manage.py migrate


# instalacion de datos
sudo ./manage.py cities_light
