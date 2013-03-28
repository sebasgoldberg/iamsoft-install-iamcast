#!/bin/bash
if [ $# -ne 8 ]
then
  echo "$0 <ID_AGENCIA> <SLUG_AGENCIA> <GMAIL_USER> <GMAIL_PASS> <DOMINIO> <UBICACION_INSTALACION> <SUPER_USUARIO> <CLAVE_SUPER_USUARIO>"
  exit 1
fi

ID_AGENCIA="$1"
SLUG_AGENCIA="$2"
GMAIL_USER="$3"
GMAIL_PASS="$4"
DOMINIO="$5"
UBICACION_INSTALACION="$6"
SUPER_USUARIO="$7"
CLAVE_SUPER_USUARIO="$8"

INSTALL_SCRIPTS_DIR="$(readlink -f "$(dirname "$0")")"

AGENCIA="${SLUG_AGENCIA}_${ID_AGENCIA}"
CARPETA_AGENCIA="$AGENCIA"
DB_NAME="$AGENCIA"
DB_USER="$AGENCIA"
DB_PASS="$CLAVE_SUPER_USUARIO"

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

cd "$UBICACION_INSTALACION"

mkdir "$CARPETA_AGENCIA"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear la carpeta $CARPETA_AGENCIA"
  exit 1
fi

cd "$CARPETA_AGENCIA"
WD_AGENCIA=$(pwd)
git init
git pull https://github.com/sebasgoldberg/agencia.git

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido realizar el pull del proyecto"
  exit 1
fi

echo "Se procede a crear base de datos y usuario de base de datos, por favor introduzca la contraseña del usuario root:"

(echo "create database $DB_NAME character set utf8;"
echo "create user '$DB_USER'@'localhost' identified by '$DB_PASS';"
echo "grant all on $DB_NAME.* to $DB_USER;"
) | mysql -u "$MYSQL_USER" "-p${MYSQL_PASS}"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear usuario $DB_USER y base de datos $DB_NAME."
  exit 1
fi


(echo "# coding=utf-8"
echo "class ambiente:"
echo "  productivo=True"
echo "  app_in_dev=None"
echo ""
echo "  dominio='${DOMINIO}:8080'"
echo ""
echo "  class db:"
echo "    name='$DB_NAME'"
echo "    user='$DB_USER'"
echo "    password='$DB_PASS'"
echo ""
echo "  project_directory = '$(pwd)/'"
echo ""
echo "  class email:"
echo "    host = 'smtp.gmail.com'"
echo "    user = '$GMAIL_USER'"
echo "    password = '$GMAIL_PASS'"
echo "    port = 587") > alternativa/ambiente.py

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear archivo alternativa/ambiente.py"
  exit 1
fi

sed -i "s#sys.path.append(.*)#sys.path.append('$(pwd)')#" alternativa/wsgi.py

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido modificar el sys.path en alternativa/wsgi.py"
  exit 1
fi

# Se crean las carpetas que no están incluidas en el repo
mkdir -p uploads/agenciados/fotos
mkdir -p uploads/cache/agenciados/fotos
mkdir -p uploads/agencias/logos
chmod 777 -R uploads

mkdir collectedstatic

./install/bootstrap.sh
"$INSTALL_SCRIPTS_DIR/install/jquery.sh" "$WD_AGENCIA" "alternativa"

export DJANGO_SETTINGS_MODULE="alternativa.settings"

echo -e "no\n" | ./manage.py syncdb
./manage.py migrate
echo -e "yes\n" | ./manage.py collectstatic
./manage.py compilemessages

echo "Se inicia la instalación de datos para la aplicación"
./manage.py loaddata $("$INSTALL_SCRIPTS_DIR/utils/get_module_path.py" 'iampacks.agencia.perfil')/fixtures/perfil_initial_data.yaml
./manage.py loadgroups

#sudo ./manage cities_light
#@todo Agregar en ña instalación del framework la carga de ciudades
CIUDADES_DB_NAME='ciudades'
echo "A continuación se realizara la copia de los datos de ciudades. Se precisa la clave del usuario root:"
(echo "insert into ${DB_NAME}.cities_light_country select * from ${CIUDADES_DB_NAME}.cities_light_country;"
echo "insert into ${DB_NAME}.cities_light_region select * from ${CIUDADES_DB_NAME}.cities_light_region;"
echo "insert into ${DB_NAME}.cities_light_city select * from ${CIUDADES_DB_NAME}.cities_light_city;"
) | mysql -u "$MYSQL_USER" "-p${MYSQL_PASS}"

sudo "$INSTALL_SCRIPTS_DIR/install/create_apache_conf.sh" "$AGENCIA" "$DOMINIO" "$WD_AGENCIA" "$INSTALL_SCRIPTS_DIR/templates"

sudo "$INSTALL_SCRIPTS_DIR/install/set_ddns.sh" "$DOMINIO" "cerebro"

exit 0
