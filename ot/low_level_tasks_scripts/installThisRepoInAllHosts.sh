#!/bin/bash

ME=$(basename ${0})
DIRNAME=$(dirname ${0})

allHosts=$(${DIRNAME}/getAllHosts.sh)

RED='\033[0;31m'
NC='\033[0m' # No Color

USERNAME_AND_PWD="${1}"

for host in ${allHosts}; do
    echo -e "${RED}${host}${NC}: "
    echo " "
    ssh root@${host} "which git || dnf install -y git"
    echo " "
    ssh root@${host} "git config --global http.sslVerify false"
    echo " "
    ssh root@${host} "[ -d /opt/scripts/.git ] || rm -fRv /opt/scripts/"
    echo " "
    echo "Updating repository in /opt/scripts : "
    echo " "
    ssh root@${host} "[ -d /opt/scripts/.git ] || git clone http://${USERNAME_AND_PWD}@gitlab-ic.scae.redsara.es/OFICINA_TECNICA/scripts.git /opt/scripts/"
    echo " "
    ssh root@${host} "cd /opt/scripts/ ; git checkout master ; git pull"
    echo " " 
done

