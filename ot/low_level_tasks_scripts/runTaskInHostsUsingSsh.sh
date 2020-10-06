#!/bin/bash

ME=$(basename ${0})
DIRNAME=$(dirname ${0})

if [ -z "$1" ] || [ "" == "$1" ] || [ -z "$2" ] || [ "" == "$2" ]; then
    echo " "
    echo "${ME}: Please provide command to run in all hosts and the hosts list. "
    echo "${ME}: Example: ${ME} 'yum clean all --verbose ; yum update --assumeyes --downloadonly ' hostname1 [hostnameN]"
    echo " "
    exit -1
fi

order="$1"
shift
hosts=$@

echo " "
echo "Hosts list: ${hosts} "
echo "Order: ${order} "
echo "Use variable host to refer to the host ... "
echo " "

RED='\033[0;31m'
NC='\033[0m' # No Color


for host in ${hosts}; do
    echo -e "${RED}${host}${NC}: ${order} "
    echo " "
    ssh -XACt root@${host} ${order}
    echo " "
done

