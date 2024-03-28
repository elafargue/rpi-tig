#!/bin/sh

# Do not run this again, the files are now configured

#docker run --rm telegraf:1.30 telegraf config > telegraf.conf
#docker run --rm -v ./influxdb/config:/etc/influxdb2 influxdb:2 influx config create --host-url http://influxdb:8086/ --active -n default -o tig-org
