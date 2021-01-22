#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ] || [ -z "${2}" ] || [ "" == "${2}" ]; then
	echo "usage: ${ME} SITE RESULT_FOLDER_NAME"
	exit 0
fi

RESULT_FOLDER_NAME="$2"
# $(echo ${1} | sed 's/\./_/g')
LOGS_FILE="openssl.log"

rm -fvr ${RESULT_FOLDER_NAME}

# SITE="${1}"
SITE_WEB="${1}"

mkdir -pv ${RESULT_FOLDER_NAME}
pushd ${RESULT_FOLDER_NAME}
# -servername ${SITE}

echo | openssl s_client -showcerts -connect ${SITE_WEB}:443 2>/dev/null >> ${LOGS_FILE}
# cat ${LOGS_FILE} | awk '/-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/' >> ${CERTS_FILE}
# echo "${ME}: Result: ${CERTS_FILE} "
# echo "${ME}: Logs:   ${LOGS_FILE} "

splitCertInPieces.sh "${LOGS_FILE}"

popd