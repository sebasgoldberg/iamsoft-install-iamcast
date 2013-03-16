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
pip install Django

# Instalacion de paquete para manejo de thumbnails
pip install django-imagekit

INSTALL_SCRIPT_DIR=$(pwd)

# Instalacion de no-ip
which noip2 > /dev/null
if [ $? -ne 0 ]
then
  cd /usr/local/src/
  wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
  tar xf noip-duc-linux.tar.gz
  cd noip-2.1.9-1/
  make install

# Se configura como servicio y en el startup
  if [ -f noip2 ]
  then
    cp templates/noip2 /etc/init.d/
    update-rc.d noip2 defaults 90
  else
    echo 'ERROR: No se ha encontrado script para servicio noip2'
  fi

fi
noip2

# Instalacion de PyYaml
cd "$INSTALL_SCRIPT_DIR"
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
service apache restart

apt-get install python-coverage

./install/django-crispy-forms.sh
./install/cities_light.sh
#./install/smart_selects.sh

./install/iamsoft.sh

echo "Framework listo para crear agencias."
