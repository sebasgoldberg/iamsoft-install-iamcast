#!/bin/bash
if [ $# -ne 6 ]
then
  echo "$0 <AGENCIA> <DOMINIO> <PUERTO_HTTP> <PUERTO_HTTPS> <WD_AGENCIA> <DIR_ARCH_CONF>"
  exit 1
fi

AGENCIA="$1"
DOMINIO="$2"
PUERTO_HTTP="$3"
PUERTO_HTTPS="$4"
WD_AGENCIA="$5"
DIR_ARCH_CONF="$6"

ARCH_CONF_APACHE2="/etc/apache2/sites-available/${AGENCIA}"
cp "${DIR_ARCH_CONF}/template-apache2-conf" "$ARCH_CONF_APACHE2"
sed -i "s#{{AGENCIA}}#${AGENCIA}#" "$ARCH_CONF_APACHE2"
sed -i "s#{{DOMINIO}}#${DOMINIO}#" "$ARCH_CONF_APACHE2"
sed -i "s#{{WD_AGENCIA}}#${WD_AGENCIA}#" "$ARCH_CONF_APACHE2"
sed -i "s#{{PUERTO_HTTP}}#${PUERTO_HTTP}#" "$ARCH_CONF_APACHE2"
sed -i "s#{{PUERTO_HTTPS}}#${PUERTO_HTTPS}#" "$ARCH_CONF_APACHE2"

ARCH_SSL_CONF_APACHE2="/etc/apache2/sites-available/${AGENCIA}-ssl"
cp "${DIR_ARCH_CONF}/template-apache2-ssl-conf" "$ARCH_SSL_CONF_APACHE2"
sed -i "s#{{AGENCIA}}#${AGENCIA}#" "$ARCH_SSL_CONF_APACHE2"
sed -i "s#{{DOMINIO}}#${DOMINIO}#" "$ARCH_SSL_CONF_APACHE2"
sed -i "s#{{WD_AGENCIA}}#${WD_AGENCIA}#" "$ARCH_SSL_CONF_APACHE2"
sed -i "s#{{PUERTO_HTTP}}#${PUERTO_HTTP}#" "$ARCH_SSL_CONF_APACHE2"
sed -i "s#{{PUERTO_HTTPS}}#${PUERTO_HTTPS}#" "$ARCH_SSL_CONF_APACHE2"

# @todo Descomentar en caso de querer generar un certificado por cada agencia. Tener en cuenta que hay que modificar para no tener que interactuar con la instalación
#cd /etc/apache2/ssl 
#/usr/sbin/make-ssl-cert /usr/share/ssl-cert/ssleay.cnf "/etc/apache2/ssl/${AGENCIA}.crt"
#CANTIDAD_LINEAS_ARCHIVO=$(wc -l "${AGENCIA}.crt" | cut -f 1 -d ' ')
#CANTIDAD_LINEAS_CLAVE=$(grep -n "END PRIVATE KEY" "${AGENCIA}.crt" | cut -f 1 -d ':')
#head -n "$CANTIDAD_LINEAS_CLAVE" "${AGENCIA}.crt" > "${AGENCIA}.key"
#CANTIDAD_LINEAS_CERTIFICADO=$(echo "$CANTIDAD_LINEAS_ARCHIVO-$CANTIDAD_LINEAS_CLAVE" | bc)
#tail -n "$CANTIDAD_LINEAS_CERTIFICADO" "${AGENCIA}.crt" > "${AGENCIA}.pem"
#rm "${AGENCIA}.crt"
#echo "Certificado (${AGENCIA}.pem) y clave (${AGENCIA}.key) generados en /etc/apache2/ssl. Tener en cuenta a la hora de configurar el sitio"

a2ensite "${AGENCIA}"
a2ensite "${AGENCIA}-ssl"
service apache2 reload

exit 0
