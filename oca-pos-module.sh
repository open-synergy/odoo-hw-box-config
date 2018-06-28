#!/usr/bin/env bash

CLONE_DIR="/home/pi/oca-pos"

if [ ! -d $CLONE_DIR ]; then
    echo "Clone Github hw_proxy_cups"
    mkdir -p "${CLONE_DIR}"
	git clone -b 8.0 --no-local --no-checkout --depth 1 https://github.com/OCA/pos.git "${CLONE_DIR}"
    cd "${CLONE_DIR}"
    git config core.sparsecheckout true
    echo "hw_*" | tee --append .git/info/sparse-checkout > /dev/null
    git read-tree -mu HEAD
fi