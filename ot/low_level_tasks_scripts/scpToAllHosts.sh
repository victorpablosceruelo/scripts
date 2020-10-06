#!/bin/bash

allHosts=$(getAllHosts.sh)

RED='\033[0;31m'
NC='\033[0m' # No Color

for host in ${allHosts}; do
    echo -e "scp -p -B -C $1 root@${RED}${host}${NC}:$2 "
    scp -p -B -C $1 root@${host}:$2
done

