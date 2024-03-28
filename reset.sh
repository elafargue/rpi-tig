#!/bin/bash

echo "Restoring default version of environment and config files"
cp env.influxdb.default env.influxdb
cp telegraf/telegraf.conf.default telegraf/telegraf.conf 

echo "Deleting InfluxDB generated config and files"
rm -rf influxdb/config/*
rm -rf influxdb/data/*

echo "Deleting Grafana data"
rm -rf grafana/data/alerting
rm -rf grafana/data/csv
rm -rf grafana/data/plugins
rm -rf grafana/data/png
rm -rf grafana/data/grafana.db

