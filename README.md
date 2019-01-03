Docker container with Mosquitto, o2s and Postgresql preconfigured with an automatically generated set of configuration files for the OwnTrack smartphone apps.

NOTE: This repository contains an old, largely UNMAINTAINED solution that may or may not work. It is not actively used or tested.

# Requirements

Development was done using Docker 1.7.0, yet older version were used before that.

# Installation and usage

If you are unfamiliar with Docker, try this on a host with Docker installed:

    $ git clone https://github.com/padelt/docker-owntracks-private-mqtt-broker
    $ cd docker-owntracks-private-mqtt-broker
    $ docker build -t owntracks .
    $ mkdir -p /docker-volumes/owntracks/
    $ echo "HOSTNAME=`hostname -f`" >> /docker-volumes/owntracks/host.config
    $ echo "PORT=28883" >> /docker-volumes/owntracks/host.config
    $ docker run -itv /docker-volumes/owntracks:/volume -p 28883:8883 --name owntracks owntracks bash
    root@4dfeb19a7da2:/#

Now inside the container:

    root@4dfeb19a7da2:/# /start.sh

The last command generated client configuration files for the OwnTrack app on your smartphone, which can be found here:

    /docker-volumes/owntracks/config/clients/client1.otrc

The smartphone will not connect to the MQTT broker (mosquitto) yet. It needs to trust the CA that was just generated. Making it trust requires that you install `ca.crt` on your smartphone:

    /docker-volumes/owntracks/config/tls/ca.crt

An alternative to installing the CA certificate is to enable a Custom Security Policy in the App. Setting the Mode to "None" and allowing untrusted certificates will work. The price is that your connection can now be trivially intercepted by a third party who can read (and modify) all the data in clear (man-in-the-middle attack).

For more details, please read this:
http://philipp.adelt.net/5/posts/2015/06/owntracks-getting-started-private-mode/

Have fun!

# Authors

* Philipp Adelt <autosort-github@philipp.adelt.net>
