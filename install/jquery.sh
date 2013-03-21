if [ $# -ne 2 ]
then
  echo "ERROR: El script debe ser llamado como: $0 <directorio de trabajo proyecto> <nombre del proyecto>"
  exit 1
fi

WD="$1"
PROJECT_NAME="$2"

cd "$WD/$PROJECT_NAME"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha encontrado ruta '$WD/$PROJECT_NAME'"
  exit 1
fi

mkdir -p static/jquery

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido crear directorio static/jquery en '$(pwd)'"
  exit 1
fi

cd "static/jquery"

URL_JQUERY='https://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js'

wget "$URL_JQUERY"

if [ $? -ne 0 ]
then
  echo "ERROR: No se ha podido descargar $URL_JQUERY en directorio $(pwd)"
  exit 1
fi

exit 0
