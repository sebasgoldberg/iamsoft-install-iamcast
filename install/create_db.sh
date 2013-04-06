if [ $# -ne 3 ]
then
  echo "ERROR: Uso: $0 <DB_NAME> <DB_USER> <DB_PASS>"
  exit 1
fi

DB_NAME="$1"
DB_USER="$2"
DB_PASS="$3"

(echo "create database $DB_NAME character set utf8;"
echo "create user '$DB_USER'@'localhost' identified by '$DB_PASS';"
echo "grant all on $DB_NAME.* to $DB_USER;"
) | mysql -u root -p
