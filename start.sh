#!/bin/bash

if [ $(grep -c "PASSWORD_TO_CHANGE" env.influxdb) -ne 0 ]; then
   echo "Default password detected for Influx database..."
   echo "Setting up a random password for this installation"
   PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
   sed -i "s/PASSWORD_TO_CHANGE/$PASSWORD/g" env.influxdb
   sed -i "s/PASSWORD_TO_CHANGE/$PASSWORD/g" env.grafana
   sed -i "s/PASSWORD_TO_CHANGE/$PASSWORD/g" telegraf/telegraf.conf
   echo "Warning: this is not enough to consider this installation is secure"
fi

if [ $(grep -c "ADMIN_TO_CHANGE" env.influxdb) -ne 0 ]; then
   echo "Default password detected for InfluxDB administrator..."
   echo "Setting up a random password for this installation"
   PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
   sed -i "s/ADMIN_TO_CHANGE/$PASSWORD/g" env.influxdb
   echo "... done"
   echo "Warning: again, the password is in the env.influxdb file now, be careful"
fi

echo "Changing ownership of grafana files to what the Docker image expects"
sudo chown -R 472:472 grafana/data

echo "Starting TIG stack in the background"
docker-compose up -d

echo -n "Waiting for InfluxDB to come up..."
sleep 20
while ! $(docker exec -it influxdb influx -password $PASSWORD -username 'admin' -execute 'show databases' | grep -q telegraf); do
  echo -n "."
done
echo " ready"

echo "Setting InfluxDB retention policy to one month to save Raspberry Pi resources"
PASSWORD="$(grep INFLUXDB_ADMIN_PASSWORD env.influxdb | awk -F '=' '{print $2}')"
docker exec -it influxdb influx -password $PASSWORD -username 'admin' -database 'telegraf' -execute 'CREATE RETENTION POLICY "one_month" ON "telegraf" DURATION 30d REPLICATION 1 DEFAULT'
echo "... done"

echo "You should be able to access Grafana at http://localhost:3000/ in a few seconds"
echo "Obviously, use the hostname of your raspberry Pi if you are connecting remotely, not 'localhost'"
echo "Default username/password is admin/admin. Please change this"
echo "The stack will keep running and will restart on reboot unless you issue a 'docker-compose stop'"
