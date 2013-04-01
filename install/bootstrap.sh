#!/bin/bash
if [ $# -eq 0 ]
then
  STATIC_DIR="$(pwd)/alternativa/static"
  echo "Se asigna por default el directorio static '${STATIC_DIR}'"
else
  STATIC_DIR="$1"
fi

cd "$STATIC_DIR"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido acceder a ${STATIC_DIR}"
  exit 1
fi

if [ -d bootstrap ]
then
  echo "ERROR: Ya existe el directorio bootstrap"
  exit 1
fi

wget http://twitter.github.com/bootstrap/assets/bootstrap.zip

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido descargar http://twitter.github.com/bootstrap/assets/bootstrap.zip"
  exit 1
fi

unzip bootstrap.zip

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido descomprimir bootstrap.zip"
  exit 1
fi

rm bootstrap.zip

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido borrar bootstrap.zip"
  exit 1
fi

exit 0
