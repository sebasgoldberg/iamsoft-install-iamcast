#!/bin/bash
echo "Se realiza la instalación del proyecto iamsoft:"

if [ $# -ne 2 ]
then
  echo "Error en la cantidad de parámetros"
  exit 1
fi 

IAMSOFT_WD="$1"
INSTALL_SCRIPTS_DIR="$2"

mkdir "$IAMSOFT_WD"

if [ $? -ne 0 ]
then
  echo "Error al crear '$IAMSOFT_WD'"
  exit 1
fi

cd "$IAMSOFT_WD"

if [ $? -ne 0 ]
then
  echo "Error al cambiar de directorio '$IAMSOFT_WD'"
  exit 1
fi

git init

if [ $? -ne 0 ]
then
  echo "Error al iniciar git en $(pwd)"
  exit 1
fi

git pull https://github.com/sebasgoldberg/iamsoft.git

if [ $? -ne 0 ]
then
  echo "Error al hacer el pull del proyecto iamsoft en $(pwd)"
  exit 1
fi

AGENCIAS_WD="$IAMSOFT_WD/agencias"

mkdir "$AGENCIAS_WD"

if [ $? -ne 0 ]
then
  echo "Error al crear '$AGENCIAS_WD'"
  exit 1
fi

chgrp www-data "$AGENCIAS_WD"

if [ $? -ne 0 ]
then
  echo "Error al cambiar grupo a www-data '$AGENCIAS_WD'"
  exit 1
fi

SUDOERS_TEMPLATE="$INSTALL_SCRIPTS_DIR/templates/sudoers"
SUDOERS_FILE="/etc/sudoers"

(cat "$SUDOERS_TEMPLATE" | sed "s#{{user}}#www-data#" | sed "s#{{install_wd}}#${INSTALL_SCRIPTS_DIR}#") >> "$SUDOERS_FILE"

if [ $? -ne 0 ]
then
  echo "Error al escribir en $SUDOERS_FILE leyendo de $SUDOERS_TEMPLATE"
  exit 1
fi

#(cat "$SUDOERS_TEMPLATE" | sed "s#{{user}}#cerebro#" | sed "s#{{install_wd}}#${INSTALL_SCRIPTS_DIR}#") >> "$SUDOERS_FILE"

#if [ $? -ne 0 ]
#then
#  echo "Error al escribir en $SUDOERS_FILE leyendo de $SUDOERS_TEMPLATE"
#  exit 1
#fi

mkdir "$IAMSOFT_WD/collectedstatic"

"$IAMSOFT_WD/manage.py" collectstatic
"$IAMSOFT_WD/manage.py" syncdb

echo "Pasos a seguir en la instalación de iamsoft:"
echo "- Crear usuario y base de datos."
echo "- Configurar ambiente.py"
echo "- Configurar servidor web"

exit 0
