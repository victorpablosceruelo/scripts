#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ] || [ -z "${2}" ] || [ "" == "${2}" ]; then
    echo " "
    echo "${ME}: Insufficient arguments. "
    echo "${ME}: Usage: ${ME} SOURCE_DIR TARGET_DIR "
    echo "${ME}: Example: "
    echo "${ME}: ${ME} /etc/pki/ca-trust/source/anchors/ /usr/lib/jvm/java-11-openjdk-amd64/lib/security/cacerts "
    exit -1
fi

SOURCE_DIR="${1}"
# /etc/pki/ca-trust/source/anchors
TARGET_DIR="${2}"

PASSWORD="changeit"
# otpgfi
echo "Password to use: ${PASSWORD} "

for file in ${SOURCE_DIR}/*; do
    fileAlias=$(basename ${file})
    echo "File alias: $fileAlias"
    fileAlias=${fileAlias%.*}
    echo "File alias: $fileAlias"
    fileAlias=$(echo "$fileAlias" | tr ' ' '.')
    echo "File alias: $fileAlias"
    echo "keytool -v -alias $fileAlias -import -file $file -keystore ${TARGET_DIR} "
    # /etc/maven-trust-store/trust.jks
    keytool -v -alias $fileAlias -import -file $file -keystore ${TARGET_DIR} -storepass ${PASSWORD}
    # /etc/maven-trust-store/trust.jks
    #-storepass ${PASSWORD}
done

echo " "
