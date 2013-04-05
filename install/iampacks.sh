#!/bin/bash
echo "Se realiza la instalación de los paquetes de iamsoft."

if [ $# -ne 1 ]
then
  echo "ERROR: Uso $0 <INSTALL_SCRIPTS_DIR>"
  exit 1
fi

INSTALL_SCRIPTS_DIR="$1"

cd "$(./utils/get_dist_packages_path.py)"

mkdir iampacks
cd iampacks
touch __init__.py

mkdir cross
cd cross
git init
git pull git://github.com/sebasgoldberg/django-iamsoft-cross.git

if [ ! -d 'estatico/static' ]
then
  mkdir 'estatico/static'
  if [ $? -ne 0 ]
  then
    echo "ERROR al crear carpeta $(pwd)/estatico/static"
    exit 1
  fi
fi

STATIC_ESTATICO="$(readlink -f 'estatico/static')"

"$INSTALL_SCRIPTS_DIR/install/bootstrap.sh" "$STATIC_ESTATICO"

if [ $? -ne 0 ]
then
  echo "Error al ejecutar $INSTALL_SCRIPTS_DIR/install/bootstrap.sh ${WD_AGENCIA}/alternativa/static"
  exit 1
fi

"$INSTALL_SCRIPTS_DIR/install/jquery.sh" "$STATIC_ESTATICO"

if [ $? -ne 0 ]
then
  echo "Error al ejecutar $INSTALL_SCRIPTS_DIR/install/jquery.sh $WD_AGENCIA alternativa"
  exit 1
fi

cd ..
mkdir agencia
cd agencia
git init
git pull git://github.com/sebasgoldberg/django-iamsoft-agencia.git

exit 0
