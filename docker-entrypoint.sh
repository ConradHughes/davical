#!/bin/bash

#SET THE TIMEZONE
apk add --update tzdata
cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
echo $TIME_ZONE > /etc/timezone
apk del tzdata

#PREPARE THE PERMISSIONS FOR VOLUMES
# $icfg contains initial settings & config files.
icfg=/initial-config
# $mcfg should be an externally mounted directory: it'll contain
# persistent configuration, calendar data and logs.  It's where config
# files are moved to on first run.
mcfg=/config
mssl=$mcfg/ssl
mkdir -p $mssl
chown -R root:root $mcfg
chmod -R 755 $mcfg
mv -n $icfg/apache.conf $mcfg/apache.conf
mv -n $icfg/davical.php $mcfg/davical.php
mv -n $icfg/supervisord.conf $mcfg/supervisord.conf
mv -n $icfg/rsyslog.conf $mcfg/rsyslog.conf
mv -n $icfg/ssl/cert.pem $mssl/cert.pem
mv -n $icfg/ssl/privkey.pem $mssl/privkey.pem
#chown -R root:root /config
#chmod -R 755 /config
chown -R root:apache $mcfg/davical.php $mssl
chmod u+rw,g+r $mssl/cert.pem $mssl/privkey.pem
chmod u+rwx,g+rx $mssl $mcfg/davical.php

#SET THE DATABASE ONLY AT THE FIRST RUN
chown -R postgres:postgres /var/lib/postgresql
if [ ! -e /var/lib/postgresql/data/pg_hba.conf ]; then
	su - postgres -c "initdb -D data --locale=$LANG"
	echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf
	echo "log_destination = 'syslog'" >> /var/lib/postgresql/data/postgresql.conf
	echo "syslog_facility = 'LOCAL1'" >> /var/lib/postgresql/data/postgresql.conf
	echo "timezone = $TIME_ZONE" >> /var/lib/postgresql/data/postgresql.conf
	sed -i "/# Put your actual configuration here/a local   davical    davical_app   trust\nlocal   davical    davical_dba   trust" /var/lib/postgresql/data/pg_hba.conf
	mkdir /var/lib/postgresql/data/backups
	chown -R postgres:postgres /var/lib/postgresql/data/backups
fi

#LAUNCH THE INIT PROCESS
exec /usr/bin/supervisord -c /etc/supervisord.conf
