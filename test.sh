(echo "drop user reliquia_2;"
echo "drop user 'reliquia_2'@'localhost';"
echo "drop database reliquia_2;")|mysql -u root -p

rm -rf ../reliquia_2

./nueva-agencia.sh 2 reliquia 'agencia.test@gmail.com' 'agencia1234' 'reliquia.iamsoft.com.ar'
