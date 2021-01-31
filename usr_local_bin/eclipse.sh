#!/bin/bash

echo "Running eclipse ... "

IS_RUNNING=$(ps -AfH | grep "eclipse " | grep -v grep)
if [ ! -z "${IS_RUNNING}" ] && [ "" != "${IS_RUNNING}" ]; then
	echo "It is still running. Kill it! "
	killall -9 eclipse
fi

# nc -zv 127.0.0.1 3128
# if [ 0 -eq $? ]; then
#    PROXY_IP=127.0.0.1
#    PROXY_PORT=3128
#else
#    PROXY_IP=10.1.0.222
#    PROXY_PORT=8080
#fi

#echo "Proxy chosen: ${PROXY_IP} ${PROXY_PORT} "
#echo " "

ECLIPSE_PATH=$(find ~/local/ -name eclipse -type f | head -n 1)
if [ -z "${ECLIPSE_PATH}" ] || [ "" == "${ECLIPSE_PATH}" ]; then
	ECLIPSE_PATH=$(find ~ -name eclipse -type f | head -n 1)
fi

# ECLIPSE_OPTS="-Dhttp.proxyHost=${PROXY_IP} -Dhttp.proxyPort=${PROXY_PORT} -Dhttps.proxyHost=${PROXY_IP} -Dhttps.proxyPort=${PROXY_PORT} -DsocksProxyHost= -DsocksProxyPort=  -Djava.net.preferIPv4Stack=true -Djava.net.useSystemProxies=true -Dorg.eclipse.ecf.provider.filetransfer.excludeContributors=org.eclipse.ecf.provider.filetransfer.httpclient4 "
# -Dhttp.proxyUser=<user>
# -Dhttp.proxyPassword=<pass>
# -Dhttp.nonProxyHosts=localhost|127.0.0.1
ECLIPSE_OPTS="-Djava.net.preferIPv4Stack=true "

echo "${ECLIPSE_PATH} -clean -refresh ${ECLIPSE_OPTS} &> /tmp/eclipse.log"

# socks_proxy=127.0.0.1:3128 
# http_proxy=${PROXY_IP}:${PROXY_PORT} https_proxy=${PROXY_IP}:${PROXY_PORT} 
${ECLIPSE_PATH} -clean -refresh ${ECLIPSE_OPTS} &> /tmp/eclipse.log 

