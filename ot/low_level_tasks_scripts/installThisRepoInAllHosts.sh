#!/bin/bash

ME=$(basename ${0})
DIRNAME=$(dirname ${0})

allHosts=$(${DIRNAME}/getAllHosts.sh)

RED='\033[0;31m'
NC='\033[0m' # No Color


for host in ${allHosts}; do
    echo -e "${RED}${host}${NC}: "
    echo " "
    ssh root@${host} "which git || dnf install -y git"
    echo " "
    ssh root@${host} "git config --global http.sslVerify false"
    echo " "
    ssh root@${host} "[ -d /opt/scripts_oficina_tecnica_de_proyectos/.git ] || rm -fRv /opt/scripts_oficina_tecnica_de_proyectos/"
    echo " "
    echo "Updating repository in /opt/scripts_oficina_tecnica_de_proyectos : "
    echo " "
    ssh root@${host} "[ -d /opt/scripts_oficina_tecnica_de_proyectos/.git ] || git clone http://Jenkins:1s3v68ftfYjHqVE5_-iM@gitlab-ic.scae.redsara.es/OFICINA_TECNICA/scripts_oficina_tecnica_de_proyectos.git /opt/scripts_oficina_tecnica_de_proyectos/"
    echo " "
    ssh root@${host} "cd /opt/scripts_oficina_tecnica_de_proyectos/ ; git checkout master ; git pull"
    echo " " 
done

