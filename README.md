# rpi-tig
Dockerized Telegraf/InfluxDB/Grafana for Rpi

I just wanted a fire-and-forget way to quickly monitor a new Pi, this is it. On a Raspbian Buster image, simply:

```
apt-get install docker.io docker-compose
```

... clone this repository, and do a single `./start.sh`. You should be set. After a couple of minutes (it's a Raspberry Pi after all), you will get the following:

- A telegraf instance gathering system stats, with statsd available on the local host for external log input
- InfluxDB storing the telegraf data
- Grafana already configured to talk to the InfluxDB instance, and preconfigured with a default system dashboard

I made a moderate effort to at least randomize the Influx database password at first run, and Grafana will remind you to change the admin password. That said, if you put this in production as is, it's really on you. There are many things that should still be done before considering this secure in any way...

Notes:

- telegraf inside a Docker container will not be able to monitor your network interfaces, obviously
- This stack works remarkably well on a Pi 3B+ (and a 4, I assume). I've had it monitor devices for months at a time with zero issues
- Thanks to docker-compose/Docker, the stack will survive a reboot
- Provisioned dashboards on Grafana cannot be saved, so they really should be used as templates, and saved as a new Dashboard if you want to edit/modify them
- Feel free to contribute PRs with useful dashboards if you have some
