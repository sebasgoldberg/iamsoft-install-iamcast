#!/bin/bash

if [ $? -ne ]
then
  echo "$0 <>"
  exit 1
fi

WD_AGENCIA="$1"
USERNAME="$2"
FIRST_NAME="$3"
LAST_NAME="$4"
EMAIL="$5"
PASSWORD="$6"

cd "$WD_AGENCIA"
  
export DJANGO_SETTINGS_MODULE="alternativa.settings"

./manage.py crear_super_usuario "--username=${USERNAME}" "--first_name=${FIRST_NAME}" "--last_name=${LAST_NAME}" "--email=${EMAIL}" "--password=${PASSWORD}"
    
