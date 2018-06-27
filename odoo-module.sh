#!/usr/bin/env bash

CLONE_DIR="/home/pi/odoo"

if [ ! -d $CLONE_DIR ]; then
    echo "Clone Github repo"
    mkdir -p "${CLONE_DIR}"
    git clone -b 8.0 --no-local --no-checkout --depth 1 https://github.com/odoo/odoo.git "${CLONE_DIR}"
    cd "${CLONE_DIR}"
    git config core.sparsecheckout true
    echo "addons/web
addons/web_kanban
addons/hw_*
addons/point_of_sale/tools/posbox/configuration
openerp/
odoo.py" | tee --append .git/info/sparse-checkout > /dev/null
    git read-tree -mu HEAD
fi

chown pi:pi -R /home/pi/odoo/