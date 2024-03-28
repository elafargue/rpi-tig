#!/bin/bash

# Step one: ensure we have Token that is defined everywhere it is needed:
# - InfluxDB of course
# - Telegraf so that it can write to Influx
# - Grafana so that it can read from Influx
if [ $(grep -c "TOKEN_TO_CHANGE" env.influxdb) -ne 0 ]; then
   echo "Default token detected for Influx database..."
   echo "Setting up a random token for this installation"
   if ! command -v openssl
   then
      PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
   else
      PASSWORD=$(openssl rand -hex 32)
   fi
   sed -i .orig "s/TOKEN_TO_CHANGE/$PASSWORD/g" env.influxdb
   sed -i .orig "s/TOKEN_TO_CHANGE/$PASSWORD/g" telegraf/telegraf.conf
   echo "Warning: this is not enough to consider this installation is secure"
   echo "         do NOT expose this to the Internet directly!"
fi

# Step two: also define an admin password for InfluxDB
if [ $(grep -c "ADMIN_TO_CHANGE" env.influxdb) -ne 0 ]; then
   echo "Default password detected for InfluxDB administrator..."
   echo "Setting up a random password for this installation"
   if ! command -v openssl
   then
      PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
   else
      PASSWORD=$(openssl rand -hex 32)
   fi
   sed -i .orig "s/ADMIN_TO_CHANGE/$PASSWORD/g" env.influxdb
   echo "... done"
   echo "Warning: again, the password is in the env.influxdb file now, be careful."
fi

echo "Changing ownership of grafana files to what the Docker image expects"
#sudo chown -R 472:472 grafana/data

echo "Starting TIG stack in the background"
docker-compose up -d

echo -n "Waiting for InfluxDB to come up..."
sleep 20
while ! $(docker exec -it influxdb influx -password $PASSWORD -username 'admin' -execute 'show databases' | grep -q telegraf); do
  echo -n "."
done
echo " ready"

#echo "Setting InfluxDB retention policy to one month to save Raspberry Pi resources"
# PASSWORD="$(grep DOCKER_INFLUXDB_INIT_PASSWORD env.influxdb | awk -F '=' '{print $2}')"
# docker exec -it influxdb influx -password $PASSWORD -username 'admin' -database 'telegraf' -execute 'CREATE RETENTION POLICY "one_month" ON "telegraf" DURATION 30d REPLICATION 1 DEFAULT'
# echo "... done"

echo "You should be able to access Grafana at http://localhost:3000/ in a few seconds"
echo "Obviously, use the hostname of your raspberry Pi if you are connecting remotely, not 'localhost'"
echo "Default username/password is admin/admin. Please change this"
echo "The stack will keep running and will restart on reboot unless you issue a 'docker-compose stop'"
