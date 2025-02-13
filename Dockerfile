#Version 0.4
#Davical + apache + postgres
#---------------------------------------------------------------------
#Default configuration: hostname: davical.example
#                       user: admin
#                       pass: 12345
#---------------------------------------------------------------------

FROM    alpine
MAINTAINER https://github.com/ConradHughes/

ENV     TIME_ZONE "Europe/Paris"
ENV     HOST_NAME "davical.example"
ENV     LANG      "en_US.UTF-8"
ENV     DAVICAL_LANG "en_US"

# config files, shell scripts
COPY    initialize_db.sh /sbin/initialize_db.sh
COPY    backup_db.sh /sbin/backup_db.sh
COPY    docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY    restore_db.sh /sbin/restore_db.sh
COPY    apache.conf /initial-config/apache.conf
COPY    davical.php /initial-config/davical.php
COPY    supervisord.conf /initial-config/supervisord.conf
COPY    rsyslog.conf /initial-config/rsyslog.conf

ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl

RUN apk add --no-cache \
    $MUSL_LOCALE_DEPS \
    && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
    && unzip musl-locales-master.zip \
      && cd musl-locales-master \
      && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
      && cd .. && rm -r musl-locales-master


# apk
RUN     apk --update add \
        sudo \
        bash \
        less \
        sed \
        supervisor \
        rsyslog \
        postgresql \
        apache2 \
        apache2-utils \
        apache2-ssl \
        php7 \
        php7-session \
        php7-intl \
        php7-openssl \
        php7-apache2 \
        php7-pgsql \
        php7-imap \
        php7-curl \
        php7-cgi \
        php7-xml \
        php7-gettext \
        php7-iconv \
        php7-ldap \
        php7-pdo \
        php7-pdo_pgsql \
        php7-calendar \
        perl \
        perl-yaml \
        perl-dbd-pg \
        perl-dbi \
        wget \
        git \
        && git clone https://gitlab.com/davical-project/awl.git /usr/share/awl/ \
        && git clone https://gitlab.com/davical-project/davical.git /usr/share/davical/ \
        && rm -rf /usr/share/davical/.git /usr/share/awl/.git/ \
        && apk del git \
# Apache
        && chown -R root:apache /usr/share/davical \
        && cd /usr/share/davical/ \
        && find ./ -type d -exec chmod u=rwx,g=rx,o=rx '{}' \; \
        && find ./ -type f -exec chmod u=rw,g=r,o=r '{}' \; \
        && find ./ -type f -name *.sh -exec chmod u=rwx,g=r,o=rx '{}' \; \
        && find ./ -type f -name *.php -exec chmod u=rwx,g=rx,o=r '{}' \; \
        && chmod o=rx /usr/share/davical/dba/update-davical-database \
        && chmod o=rx /usr/share/davical \
        && chown -R root:apache /usr/share/awl \
        && cd /usr/share/awl/ \
        && find ./ -type d -exec chmod u=rwx,g=rx,o=rx '{}' \; \
        && find ./ -type f -exec chmod u=rw,g=r,o=r '{}' \; \
        && find ./ -type f -name *.sh -exec chmod u=rwx,g=rx,o=r '{}' \; \
        && find ./ -type f -name *.sh -exec chmod u=rwx,g=r,o=rx '{}' \; \
        && chmod o=rx /usr/share/awl \
        && sed -i /CustomLog/s/^/#/ /etc/apache2/httpd.conf \
        && sed -i /ErrorLog/s/^/#/ /etc/apache2/httpd.conf \
        && sed -i /TransferLog/s/^/#/ /etc/apache2/httpd.conf \
        && sed -i /CustomLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
        && sed -i /ErrorLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
        && sed -i /TransferLog/s/^/#/ /etc/apache2/conf.d/ssl.conf \
# Huge calendar imports break on PHP's 30s time limit; 600s is enough.
        && sed -i 's/^\(max_execution_time\s*=\s*\)[0-9]\+/\1600/' /etc/php7/php.ini \
# permissions for shell scripts and config files
        && chmod 0755 /sbin/initialize_db.sh \
        && chmod 0755 /sbin/backup_db.sh  \
        && chmod 0755 /sbin/docker-entrypoint.sh \
        && chmod 0755 /sbin/restore_db.sh \
        && mkdir /etc/davical /etc/supervisor.d/ /etc/rsyslog.d \
        && echo -e "\$IncludeConfig /etc/rsyslog.d/*.conf" > /etc/rsyslog.conf \
        && chown -R root:apache /etc/davical \
        && chmod -R u=rwx,g=rx,o= /etc/davical \
        && chown root:apache /initial-config/davical.php \
        && chmod u+rwx,g+rx /initial-config/davical.php \
        && ln -s /config/apache.conf /etc/apache2/conf.d/davical.conf \
        && ln -s /config/davical.php /etc/davical/config.php \
        && ln -s /sbin/backup_db.sh /etc/periodic/daily/backup \
        && rm -f /etc/supervisord.conf \
        && ln -s /config/supervisord.conf /etc/supervisord.conf \
        && ln -s /config/rsyslog.conf /etc/rsyslog.d/rsyslog-davical.conf \
# clean-up etc
        && rm -rf /var/cache/apk/* \
        && mkdir -p /run/apache2 \
        && mkdir -p /var/log/apache2 \
        && chown root:apache /var/log/apache2 \
        && mkdir -p /run/postgresql \
        && chown postgres.postgres /run/postgresql \
#       && chmod a+w /run/postgresql \
# build-translations
	    && cd /usr/share/davical \
	    && make all


EXPOSE 443
VOLUME  ["/var/lib/postgresql/data/","/config"]
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
