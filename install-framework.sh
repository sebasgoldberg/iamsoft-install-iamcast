#!/bin/bash
INSTALL_SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"

apt-get install make
apt-get install bc
apt-get install apache2
apt-get install mysql-server
apt-get install cython
apt-get install libapache2-mod-wsgi
apt-get install python-mysqldb
apt-get install python-imaging
apt-get install mercurial #necesario para hacer el pull de algunos pagetes a ser instalados
apt-get install unzip
apt-get install gettext
apt-get install python-pip
apt-get install curl

pip install Django==1.4.3

# Instalacion de paquete para manejo de thumbnails
pip install django-imagekit
pip install requests

# Instalacion de PyYaml
mkdir pyyaml
cd pyyaml
hg clone https://bitbucket.org/xi/pyyaml
cd pyyaml
python setup.py install
cd ../..
rm -rf pyyaml

# Generación de los certificados:
if [ ! -d /etc/apache2/ssl ]
then
  mkdir /etc/apache2/ssl 
fi

a2enmod ssl
a2enmod rewrite
service apache restart

apt-get install python-coverage

./install/django-crispy-forms.sh
./install/cities_light.sh
#./install/smart_selects.sh

./install/iampacks.sh "$INSTALL_SCRIPTS_DIR"

IAMSOFT_WD="$(readlink -f "$INSTALL_SCRIPTS_DIR/../iamsoft")"

./install/iamsoft.sh "$IAMSOFT_WD" "$INSTALL_SCRIPTS_DIR"

CIUDADES_WD="$(readlink -f "$INSTALL_SCRIPTS_DIR/..")/ciudades"

mkdir "$CIUDADES_WD"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear carpeta $CIUDADES_WD"
  exit 1
fi

cd "$CIUDADES_WD"

"$INSTALL_SCRIPTS_DIR/install/install_ciudades.sh"

echo "Framework listo para crear agencias."
