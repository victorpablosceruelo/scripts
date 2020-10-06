#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ] || [ -z "${2}" ] || [ "" == "${2}" ] || [ -z "${3}" ] || [ "" == "${3}" ]; then
	echo " "
	echo "${ME}: usage: ${ME} host port domain fileName "
	echo "${ME}: example: ${ME} redmine-ic.scae.redsara.es 443 scae.redsara.es scae_redsara_es "
	echo " "
	exit -1
fi

HOST_NAME="${1}"
PORT="${2}"
DOMAIN="${3}"
SERVER_ROOT_CERTIFICATE="${4}"

echo "Removing file $SERVER_ROOT_CERTIFICATE ... "
rm -fv ${SERVER_ROOT_CERTIFICATE} ${SERVER_ROOT_CERTIFICATE}.der ${SERVER_ROOT_CERTIFICATE}.pem ${SERVER_ROOT_CERTIFICATE}.cer ${SERVER_ROOT_CERTIFICATE}.openssl

echo "Getting the certificate for $HOST_NAME:$PORT ... "

# No vale:
# CERTS=$(echo -n | openssl s_client -servername $HOST_NAME -connect $HOST_NAME:$PORT -showcerts | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')
# echo "$CERTS" | awk -v RS="-----BEGIN CERTIFICATE-----" 'NR > 1 { printf RS $0 > "'$SERVER_ROOT_CERTIFICATE'"; close("'$SERVER_ROOT_CERTIFICATE'") }'


openssl s_client -servername ${DOMAIN} -connect $HOST_NAME:$PORT </dev/null 2>/dev/null > ${SERVER_ROOT_CERTIFICATE}.openssl
cat ${SERVER_ROOT_CERTIFICATE}.openssl | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${SERVER_ROOT_CERTIFICATE}.pem

# you may also convert to a certificate for desktop
openssl x509 -inform PEM -in ${SERVER_ROOT_CERTIFICATE}.pem -outform DER -out ${SERVER_ROOT_CERTIFICATE}.der

# No vale:
# openssl x509 -in ${SERVER_ROOT_CERTIFICATE}.openssl -text -outform DER -out $SERVER_ROOT_CERTIFICATE

echo " "

