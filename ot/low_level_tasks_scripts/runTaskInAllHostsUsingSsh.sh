#!/bin/bash

ME=$(basename ${0})
DIRNAME=$(dirname ${0})

if [ -z "$1" ] || [ "" == "$1" ]; then
    echo " "
    echo "${ME}: Please provide command to run in all hosts. "
    echo "${ME}: Example: ${ME} 'yum clean all --verbose ; yum update --assumeyes --downloadonly '"
    echo " "
    exit -1
fi

allHosts=$(${DIRNAME}/getAllHosts.sh)

echo "Use variable host to refer to the host ... "

RED='\033[0;31m'
NC='\033[0m' # No Color


for host in ${allHosts}; do
    echo -e "${RED}${host}${NC}: ${1} "
    echo " "
    ssh root@${host} ${1}
    echo " "
done

