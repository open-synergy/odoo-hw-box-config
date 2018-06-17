#!/bin/bash

# copy file
cp odoo-hw-box-config.sh /usr/bin
cp config /etc/odoo-hw-box-config.conf

# make sure odoo-hw-box-config run after terminal login
echo "odoo-hw-box-config.sh" >> .bashrc
