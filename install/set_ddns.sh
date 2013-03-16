#!/bin/bash
if [ $# -ne 2 ]
then
  echo "$0 <DOMINIO> <USER>"
  exit 1
fi

DOMINIO="$1"
USER="$2"

echo "*/5 * * * * wget -O - 'https://zonomi.com/app/dns/dyndns.jsp?host=${DOMINIO}&api_key=46006240854783486364069375239266787441' >> ~/zonomi.xml" >> "/var/spool/cron/crontabs/${USER}"
