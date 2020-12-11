#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ]; then
	echo "usage: ${ME} SITE "
	exit 0
fi

FILE_NAME=$(echo ${1} | sed 's/\./_/g')
CERTS_FILE="${FILE_NAME}_cert.cer"
LOGS_FILE="${FILE_NAME}_cert.log"

rm -fv ${LOGS_FILE} ${CERTS_FILE}

# SITE="${1}"
SITE_WEB="${1}"

# -servername ${SITE}

echo | openssl s_client -showcerts -connect ${SITE_WEB}:443 2>/dev/null >> ${LOGS_FILE}
cat ${LOGS_FILE} | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> ${CERTS_FILE}

echo "Result: ${CERTS_FILE} "
echo "Logs:   ${LOGS_FILE} "
