#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ -z "${2}" ] || [ "" == "${1}" ] || [ "" == "${2}" ]; then
	echo "usage: ${ME} SITE SITE_WEB"
	exit 0
fi

SITE="${1}"
SITE_WEB="${2}"

echo | openssl s_client -showcerts -servername ${SITE} -connect ${SITE_WEB}:443 2>/dev/null | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> company-internal-certificate.cer

