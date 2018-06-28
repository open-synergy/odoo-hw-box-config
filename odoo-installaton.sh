#!/usr/bin/env bash
OE="odoo-server"

apt-get update && apt-get -y upgrade

PKGS_TO_INSTALL="adduser postgresql-client python python-dateutil python-decorator python-docutils python-feedparser python-imaging python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid python-passlib python-psutil python-psycopg2 python-babel python-pychart python-pydot python-pyparsing python-pypdf python-reportlab python-requests python-simplejson python-tz python-unittest2 python-vatnumber python-vobject python-werkzeug python-xlwt python-yaml postgresql python-gevent python-serial python-pip python-dev localepurge vim mc mg screen iw hostapd isc-dhcp-server git rsync console-data lightdm xserver-xorg-video-fbdev xserver-xorg-input-evdev iceweasel xdotool unclutter x11-utils openbox python-netifaces rpi-update"
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes install ${PKGS_TO_INSTALL}

sudo apt-get install cups

pip install pyusb==1.0.0b1
pip install qrcode
pip install evdev
pip install simplejson
pip install unittest2

pip install --upgrade websocket_client

groupadd usbusers
usermod -a -G usbusers pi
usermod -a -G lp pi

sudo -u postgres createuser -s pi
mkdir /var/log/odoo
chown pi:pi /var/log/odoo

echo -e "* Create server config file"
if [ ! -f /etc/$OE.conf ]; then
	sudo cp $OE.conf /etc/
	sudo chown pi:pi /etc/$OE.conf
	sudo chmod 640 /etc/$OE.conf
fi

if [ ! -d /home/pi/odoo ]; then
	./odoo-module.sh
fi

echo -e "* Add addons_path"
sudo su pi -c "echo 'addons_path=/home/pi/odoo/addons,/home/pi/odoo/openerp/addons' >> /etc/$OE.conf"

echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE
echo '### BEGIN INIT INFO' >> ~/$OE
echo '# Provides: $OE' >> ~/$OE
echo '# Required-Start: $remote_fs $syslog' >> ~/$OE
echo '# Required-Stop: $remote_fs $syslog' >> ~/$OE
echo '# Should-Start: $network' >> ~/$OE
echo '# Should-Stop: $network' >> ~/$OE
echo '# Default-Start: 2 3 4 5' >> ~/$OE
echo '# Default-Stop: 0 1 6' >> ~/$OE
echo '# Short-Description: Enterprise Business Applications' >> ~/$OE
echo '# Description: ODOO Business Applications' >> ~/$OE
echo '### END INIT INFO' >> ~/$OE
echo 'PATH=/bin:/sbin:/usr/bin' >> ~/$OE
echo "DAEMON=/home/pi/odoo/odoo.py" >> ~/$OE
echo "NAME=odoo" >> ~/$OE
echo "DESC=odoo" >> ~/$OE
echo '' >> ~/$OE
echo '# Specify the user name (Default: odoo).' >> ~/$OE
echo "USER=pi" >> ~/$OE
echo '' >> ~/$OE
echo '# Specify an alternate config file (Default: /etc/openerp-server.conf).' >> ~/$OE
echo "CONFIGFILE=\"/etc/$OE.conf\"" >> ~/$OE
echo '' >> ~/$OE
echo '# pidfile' >> ~/$OE
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE
echo '' >> ~/$OE
echo '# Additional options that are passed to the Daemon.' >> ~/$OE
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE
echo 'checkpid() {' >> ~/$OE
echo '[ -f $PIDFILE ] || return 1' >> ~/$OE
echo 'pid=`cat $PIDFILE`' >> ~/$OE
echo '[ -d /proc/$pid ] && return 0' >> ~/$OE
echo 'return 1' >> ~/$OE
echo '}' >> ~/$OE
echo '' >> ~/$OE
echo 'case "${1}" in' >> ~/$OE
echo 'start)' >> ~/$OE
echo 'echo -n "Starting ${DESC}: "' >> ~/$OE
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE
echo 'echo "${NAME}."' >> ~/$OE
echo ';;' >> ~/$OE
echo 'stop)' >> ~/$OE
echo 'echo -n "Stopping ${DESC}: "' >> ~/$OE
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE
echo '--oknodo' >> ~/$OE
echo 'echo "${NAME}."' >> ~/$OE
echo ';;' >> ~/$OE
echo '' >> ~/$OE
echo 'restart|force-reload)' >> ~/$OE
echo 'echo -n "Restarting ${DESC}: "' >> ~/$OE
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE
echo '--oknodo' >> ~/$OE
echo 'sleep 1' >> ~/$OE
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE
echo 'echo "${NAME}."' >> ~/$OE
echo ';;' >> ~/$OE
echo '*)' >> ~/$OE
echo 'N=/etc/init.d/${NAME}' >> ~/$OE
echo 'echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE
echo 'exit 1' >> ~/$OE
echo ';;' >> ~/$OE
echo '' >> ~/$OE
echo 'esac' >> ~/$OE
echo 'exit 0' >> ~/$OE

echo -e "* Security Init File"
sudo mv ~/$OE /etc/init.d/$OE
sudo chmod 755 /etc/init.d/$OE
sudo chown root: /etc/init.d/$OE

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE defaults