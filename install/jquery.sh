#!/bin/bash
if [ $# -ne 1 ]
then
  echo "ERROR: El script debe ser llamado como: $0 <STATIC_DIR>"
  exit 1
fi

STATIC_DIR="$1"
cd "$STATIC_DIR"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha encontrado ruta '$STATIC_DIR'"
  exit 1
fi

mkdir jquery

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear directorio static/jquery en '$(pwd)'"
  exit 1
fi

cd "jquery"

URL_JQUERY='https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'

wget "$URL_JQUERY"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido descargar $URL_JQUERY en directorio $(pwd)"
  exit 1
fi

exit 0
