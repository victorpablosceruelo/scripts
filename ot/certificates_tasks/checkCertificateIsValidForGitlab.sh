#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ]; then
	echo " "
	echo "${ME}: usage: ${ME} path_to_certificate_file "
	echo " "
fi

echo " "
echo "${ME}: Checking certificate in file ${1}..."
echo " "

if [ -f "${1}.pem" ]; then
	echo "${ME}: /opt/gitlab/embedded/bin/openssl x509 -in ${1}.pem -text -noout"
	/opt/gitlab/embedded/bin/openssl x509 -in ${1}.pem -text -noout
fi

if [ -f "${1}.der" ]; then
	echo "${ME}: /opt/gitlab/embedded/bin/openssl x509 -inform DER -in ${1}.der -text -noout"
	/opt/gitlab/embedded/bin/openssl x509 -inform DER -in ${1}.der -text -noout
fi

echo " "

