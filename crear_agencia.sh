#!/bin/bash
if [ $# -ne 12 ]
then
  echo "$0 <ID_AGENCIA> <SLUG_AGENCIA> <GMAIL_USER> <GMAIL_PASS> <DOMINIO> <PUERTO_HTTP> <PUERTO_HTTPS> <UBICACION_INSTALACION> <SUPER_USUARIO> <CLAVE_BASE_DATOS> <ZONOMI_API_KEY> <IDIOMA>"
  exit 1
fi

ID_AGENCIA="$1"
SLUG_AGENCIA="$2"
GMAIL_USER="$3"
GMAIL_PASS="$4"
DOMINIO="$5"
PUERTO_HTTP="$6"
PUERTO_HTTPS="$7"
UBICACION_INSTALACION="$8"
SUPER_USUARIO="$9"
CLAVE_BASE_DATOS="${10}"
ZONOMI_API_KEY="${11}"
IDIOMA="${12}"

INSTALL_SCRIPTS_DIR="$(readlink -f "$(dirname "$0")")"

AGENCIA="${SLUG_AGENCIA}_${ID_AGENCIA}"
CARPETA_AGENCIA="$AGENCIA"
DB_NAME="$AGENCIA"
DB_USER="$AGENCIA"
DB_PASS="$CLAVE_BASE_DATOS"

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

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido acceder a la ubicación de instalación $UBICACION_INSTALACION"
  exit 1
fi

WD_AGENCIA="${UBICACION_INSTALACION}/${CARPETA_AGENCIA}"

mkdir "$WD_AGENCIA"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear la carpeta $WD_AGENCIA"
  exit 1
fi

cd "$WD_AGENCIA"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido acceder a la carpeta de trabajo de la agencia: $WD_AGENCIA"
  exit 1
fi

git init
git pull https://github.com/sebasgoldberg/agencia.git

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido realizar el pull del proyecto"
  exit 1
fi

echo "Se procede a crear base de datos y usuario de base de datos (puede ser que sea necesario introducir la contraseña del usuario root)."

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
echo "  dominio='${DOMINIO}'"
echo "  puerto_http='${PUERTO_HTTP}'"
echo "  puerto_https='${PUERTO_HTTPS}'"
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
echo "    port = 587"
echo "  @staticmethod"
echo "  def get_base_url():"
echo "    return ambiente.get_base_http()"
echo ""
echo "  @staticmethod"
echo "  def get_base_http():"
echo "    return 'http://%s:%s'%(ambiente.dominio,ambiente.puerto_http)"
echo ""
echo "  @staticmethod"
echo "  def get_base_https():"
echo "    return 'https://%s:%s'%(ambiente.dominio,ambiente.puerto_https)") > alternativa/ambiente.py

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

export DJANGO_SETTINGS_MODULE="alternativa.settings"

echo -e "no\n" | ./manage.py syncdb

if [ $? -ne 0 ]
then
  echo "Error al ejecutar syncdb"
  exit 1
fi

./manage.py migrate

if [ $? -ne 0 ]
then
  echo "Error al ejecutar migrate"
  exit 1
fi

echo -e "yes\n" | ./manage.py collectstatic

if [ $? -ne 0 ]
then
  echo "Error al ejecutar collectstatic"
  exit 1
fi

./manage.py compilemessages

if [ $? -ne 0 ]
then
  echo "Error al ejecutar compilemessages"
  exit 1
fi

echo "Se inicia la instalación de datos para la aplicación"
./manage.py loadperfil "--idioma=$IDIOMA"

if [ $? -ne 0 ]
then
  echo "Error al ejecutar cargar fixtures de perfiles"
  exit 1
fi

./manage.py loadgroups

if [ $? -ne 0 ]
then
  echo "Error al ejecutar loadgroups"
  exit 1
fi

#sudo ./manage cities_light
#@todo Agregar en ña instalación del framework la carga de ciudades
CIUDADES_DB_NAME='ciudades'
echo "A continuación se realizara la copia de los datos de ciudades. Se precisa la clave del usuario root:"
(echo "insert into ${DB_NAME}.cities_light_country select * from ${CIUDADES_DB_NAME}.cities_light_country;"
echo "insert into ${DB_NAME}.cities_light_region select * from ${CIUDADES_DB_NAME}.cities_light_region;"
echo "insert into ${DB_NAME}.cities_light_city select * from ${CIUDADES_DB_NAME}.cities_light_city;"
) | mysql -u "$MYSQL_USER" "-p${MYSQL_PASS}"

if [ $? -ne 0 ]
then
  echo "Error al cargar ciudades, regiones y paises"
  exit 1
fi

sudo "$INSTALL_SCRIPTS_DIR/install/create_apache_conf.sh" "$AGENCIA" "$DOMINIO" "$PUERTO_HTTP" "$PUERTO_HTTPS" "$WD_AGENCIA" "$INSTALL_SCRIPTS_DIR/templates"

if [ $? -ne 0 ]
then
  echo "Error al crear la configuración del servidor WEB"
  exit 1
fi

sudo "$INSTALL_SCRIPTS_DIR/install/set_ddns.sh" "$DOMINIO" "cerebro" "$ZONOMI_API_KEY"

if [ $? -ne 0 ]
then
  echo "Error al configurar DNS."
  exit 1
fi

exit 0
