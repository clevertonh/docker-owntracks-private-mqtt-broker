FROM debian:stretch

MAINTAINER Philipp Adelt <autosort-github@philipp.adelt.net>

RUN apt-get update && apt-get upgrade -y && apt-get install -y gnupg apt-transport-https

# Everthing for the MQTT Broker "mosquitto"
ADD files/mosquitto-stretch.list /etc/apt/sources.list.d/mosquitto-stretch.list
ADD files/mosquitto-repo.gpg.key /tmp/mosquitto-repo.gpg.key
RUN apt-key add /tmp/mosquitto-repo.gpg.key

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y mosquitto mosquitto-clients vim nano supervisor openssl pwgen git python-pip postgresql python-dev default-libmysqlclient-dev python-psycopg2 net-tools

RUN adduser --system --disabled-password --disabled-login mosquitto

RUN bash -c 'echo alias ll=\"ls -l\" >> /root/.bashrc'

COPY files/mosquitto.conf.default /tmp/mosquitto.conf.default

# 'generate-CA.sh' is local copy of https://github.com/owntracks/tools/blob/master/TLS/generate-CA.sh
COPY files/generate-CA.sh /tmp/generate-CA.sh
RUN chmod +x /tmp/generate-CA.sh

# Postgresql for persistent storage via o2s
# Allow all users from localhost
RUN echo "host all  all    127.0.0.0/8  md5" >> /etc/postgresql/9.6/main/pg_hba.conf

USER postgres
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    psql --command "CREATE USER o2s WITH SUPERUSER PASSWORD 'o2s';" &&\
    psql --command "CREATE DATABASE o2s WITH OWNER o2s;" &&\
    createdb -O docker docker

USER root

# Install Pista
RUN git clone https://github.com/padelt/pista.git /pista
RUN pip install -r /pista/requirements.txt
COPY files/o2s.conf /pista/o2s.conf

COPY files/start.sh /start.sh
COPY files/listen-mqtt.sh /listen-mqtt.sh
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/pista-inject-users.sh /tmp/pista-inject-users.sh
RUN chmod +x /*.sh /tmp/*.sh

# Install mqttwarn with enough to fill a Google Docs Table
RUN git clone https://github.com/jpmens/mqttwarn.git /opt/mqttwarn
RUN pip install gspread && pip install google-api-python-client
COPY files/mqttwarn.ini.default /tmp/mqttwarn.ini.default

VOLUME ["/volume"]

EXPOSE 8883 9001 5432

CMD ["/bin/bash", "/start.sh"]
