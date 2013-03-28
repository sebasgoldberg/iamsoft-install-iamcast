#!/bin/bash
if [ $# -ne 1 ]
then
  echo "ERROR de uso: $0 <AGENCIA>"
fi

AGENCIA="$1"

AGENCIA_SSL="${AGENCIA}-ssl"

a2dissite "$AGENCIA"
a2dissite "$AGENCIA_SSL"
service apache2 reload

rm "/etc/apache2/sites-available/$AGENCIA"
rm "/etc/apache2/sites-available/$AGENCIA_SSL"
