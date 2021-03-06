#!/bin/bash

# Source library
. ../utils/helper.sh

check_env || exit 1
check_running_cp 4.1 || exit 

./stop.sh

get_ksql_ui
echo "auto.offset.reset=earliest" >> $CONFLUENT_HOME/etc/ksql/ksql-server.properties
confluent start

cat mysql_users.txt | kafka-console-producer --broker-list localhost:9092 --topic mysql_users --property parse.key=true --property key.separator=:

if is_ce; then PROPERTIES=" propertiesFile=$CONFLUENT_HOME/etc/ksql/datagen.properties"; else PROPERTIES=""; fi
ksql-datagen quickstart=ratings format=avro topic=ratings maxInterval=500 $PROPERTIES &>/dev/null &
sleep 5

ksql http://localhost:8088 <<EOF
run script 'ksql.commands';
exit ;
EOF
