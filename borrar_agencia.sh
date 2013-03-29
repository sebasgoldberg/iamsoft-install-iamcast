#!/bin/bash
if [ $# -ne 5 ]
then
  echo "$0 <ID_AGENCIA> <SLUG_AGENCIA> <UBICACION_INSTALACION_AGENCIAS> <DOMINIO> <ZONOMI_API_KEY>"
  exit 1
fi

ID="$1"
SLUG="$2"
UBICACION_INSTALACION="$3"
AGENCIA="${SLUG}_${ID}"
DOMINIO="$4"
ZONOMI_API_KEY="$5"

INSTALL_SCRIPTS_DIR="$(readlink -f "$(dirname "$0")")"

cd "$INSTALL_SCRIPTS_DIR"

MYSQL_USER="$(python -c "from ambiente import ambiente; print ambiente.mysql.usuario")"
if [ $? -ne 0 ]
then
  echo "No se ha podido obtener usuario mysql de ambiente.py"
  exit 1
fi

MYSQL_PASS="$(python -c "from ambiente import ambiente; print ambiente.mysql.clave")"
if [ $? -ne 0 ]
then
  echo "No se ha podido obtener clave mysql de ambiente.py"
  exit 1
fi

(echo "drop user '${SLUG}_${ID}';"
echo "drop user '${SLUG}_${ID}'@'localhost';"
echo "drop database ${SLUG}_${ID};")|mysql -u "$MYSQL_USER" "-p$MYSQL_PASS"

cd "$UBICACION_INSTALACION"

rm -rf "${SLUG}_${ID}"

sudo "$INSTALL_SCRIPTS_DIR/uninstall/disable_apache2_conf.sh" "${AGENCIA}"

sudo "$INSTALL_SCRIPTS_DIR/uninstall/unset_ddns.sh" "$DOMINIO" "cerebro" "$ZONOMI_API_KEY"
