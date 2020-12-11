#!/bin/bash

ME=$(basename ${0})
CERTS_FILE="certificates.cer"

if [ -z "${1}" ] || [ "" == "${1}" ]; then
	echo "usage: ${ME} SITE "
	exit 0
fi

rm -fv ${ME}.log
rm -fv ${CERTS_FILE}

# SITE="${1}"
SITE_WEB="${1}"

# -servername ${SITE}

echo | openssl s_client -showcerts -connect ${SITE_WEB}:443 2>/dev/null >> ${ME}.log 
cat ${ME}.log | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> ${CERTS_FILE}

echo "Result: ${CERTS_FILE} "
echo "Logs:   ${ME}.log "
