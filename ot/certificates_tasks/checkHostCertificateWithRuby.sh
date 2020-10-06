#!/bin/bash

ME=$(basename ${0})
DIRNAME=$(dirname ${0})

if [ -z "$1" ] || [ "" == "${1}" ]; then 
	echo "${ME}: usage: ${ME} hostname "
	exit -1
fi

rm -fv /tmp/logs_${ME}*.txt
exec 2>/tmp/logs_${ME}.txt

${DIRNAME}/ruby.sh -e "puts ruby interpreter has been found    ✅ "
if [ 0 -ne $? ]; then
	which dnf
	if [ 0 -ne $? ]; then
		yum install -y ruby
	else
		dnf install -y ruby
	fi
fi

echo " "
echo "- Ruby certificates located in: "
RUBY_CERT_DIR=$(${DIRNAME}/ruby.sh -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_DIR')
echo $RUBY_CERT_DIR

if [ ! -z "${RUBY_CERT_DIR}" ] && [ "" != ${RUBY_CERT_DIR} ] && [ -d ${RUBY_CERT_DIR} ]; then
	echo "- Ruby certificates folder contents (${RUBY_CERT_DIR}):"
	ls -la ${RUBY_CERT_DIR}
fi

echo " "
echo "- Ruby certificates file: "
RUBY_CERT_FILE=$(${DIRNAME}/ruby.sh -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')
echo $RUBY_CERT_FILE

if [ ! -z "${RUBY_CERT_FILE}" ] && [ "" != ${RUBY_CERT_FILE} ] && [ -f ${RUBY_CERT_FILE} ]; then
	echo "- Ruby certificates main file: "
	ls -la ${RUBY_CERT_FILE}
fi

echo " "

HOST=${1}

echo "- Checking connectivity to host and, specifically, to ports 80 and 443 "
echo "   ping ${HOST} -c 5 -w 10 "
ping "${HOST}" -c 5 -w 10
echo "nc -zv ${HOST} 80"
nc -zv ${HOST} 80
echo "nc -zv ${HOST} 443"
nc -zv ${HOST} 443

echo " "
echo "curl --insecure --silent --show-error --proto -all,https "https://${HOST}:443" --output /tmp/logs_${ME}_insecure_curl.txt "
curl --insecure --silent --show-error --proto -all,https "https://${HOST}:443" --output /tmp/logs_${ME}_insecure_curl.txt
echo "Curl result: $? "
echo " "

echo "- Checking host certificates chain with Ruby: "
${DIRNAME}/ruby.sh ${DIRNAME}/checkRubyHttpsCertsChainForHost.rb "$@"

echo " "
echo "curl --silent --show-error --proto -all,https "https://${HOST}:443" --output /tmp/logs_${ME}_secure_curl.txt "
curl --insecure --silent --show-error --proto -all,https "https://${HOST}:443" --output /tmp/logs_${ME}_secure_curl.txt
echo "Curl result: $? "
echo " "


