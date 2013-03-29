#!/bin/bash
if [ $# -ne 3 ]
then
  echo "$0 <DOMINIO> <USER> <API_KEY>"
  exit 1
fi

DOMINIO="$1"
USER="$2"
API_KEY="$3"

sed -i "/https:\/\/zonomi.com\/app\/dns\/dyndns.jsp?host=${DOMINIO}&api_key=${API_KEY}/d" "/var/spool/cron/crontabs/${USER}"

wget -O - "https://zonomi.com/app/dns/dyndns.jsp?action=DELETE&name=${DOMINIO}&type=A&api_key=${API_KEY}"
