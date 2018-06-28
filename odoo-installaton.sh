#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

OE="odoo-server"

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

sudo apt-get update && apt-get -y upgrade > /dev/null

PKGS_TO_INSTALL="adduser postgresql-client python postgresql \
python-jinja2 python-ldap python-libxslt1 python-lxml python-mako \
python-mock python-openid python-psycopg2 python-psutil python-babel \
python-pychart python-pydot python-pyparsing python-reportlab \
python-simplejson python-tz python-unittest2 python-vatnumber \
python-vobject python-webdav python-werkzeug python-xlwt python-yaml \
python-zsi poppler-utils python-pip python-passlib python-decorator \
python-pypdf gcc python-dev python-setuptools python-babel \
python-feedparser python-reportlab-accel python-zsi python-openssl \
python-egenix-mxdatetime python-jinja2 python-unittest2 python-mock \
python-docutils lptools python-psutil python-paramiko \
poppler-utils python-pdftools antiword software-properties-common \
python-psycopg2 python-requests python-openid
python-dateutil python-docutils python-feedparser \
python-gevent python-serial localepurge vim mc mg cups \
python-netifaces git"

apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PKGS_TO_INSTALL}

apt-get clean
localepurge

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

echo -e "* Cloning Odoo Modules"
if [ ! -d /home/pi/odoo ]; then
    ./odoo-module.sh
fi

echo -e "* Create server config file"
if [ ! -f /etc/$OE.conf ]; then
    sudo cp $OE.conf /etc/
    sudo chown pi:pi /etc/$OE.conf
    sudo chmod 640 /etc/$OE.conf
    echo -e "* Add addons_path"
    sudo su pi -c "echo 'addons_path=/home/pi/odoo/addons,/home/pi/odoo/openerp/addons' >> /etc/$OE.conf"
fi

if [ ! -f /etc/init.d/$OE ]; then
    echo -e "* Security Init File"
    sudo cp $OE /etc/init.d/$OE
    sudo chmod 755 /etc/init.d/$OE
    sudo chown root: /etc/init.d/$OE

    echo -e "* Start ODOO on Startup"
    sudo update-rc.d $OE defaults
fi

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE start"
echo "-----------------------------------------"
echo "Done! The Odoo server is up and running."
echo "-----------------------------------------"
