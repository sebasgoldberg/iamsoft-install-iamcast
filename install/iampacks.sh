#!/bin/bash
echo "Se realiza la instalación de los paquetes de iamsoft."

cd "$(./utils/get_dist_packages_path.py)"

mkdir iampacks
cd iampacks
touch __init__.py

mkdir cross
cd cross
git pull git://github.com/sebasgoldberg/django-iamsoft-cross.git

cd ..
mkdir agencia
cd agencia
git pull git://github.com/sebasgoldberg/django-iamsoft-agencia.git

exit 0
