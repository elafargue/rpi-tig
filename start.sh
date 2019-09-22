#!/bin/bash

if [ $(grep -c "PASSWORD_TO_CHANGE" env.influxdb) -ne 0 ]; then
   echo "Default password detected for Influx database..."
   echo "Setting up a random password for this installation"
   PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
   sed -i "s/PASSWORD_TO_CHANGE/$PASSWORD/g" env.influxdb
   sed -i "s/PASSWORD_TO_CHANGE/$PASSWORD/g" telegraf/telegraf.conf
   echo "Warning: this is not enough to consider this installation is secure"
fi

echo "Changing ownership of grafana files to what the Docker image expects"
sudo chown -R 472:472 grafana/data

echo "Starting TIG stack in the background"
docker-compose up -d


echo "You should be able to access Grafana at http://localhost:3000/ in a few seconds"
echo "The stack will keep running and will restart on reboot unless you issue a 'docker-compose stop'"
