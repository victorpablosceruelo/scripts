#!/bin/bash

ME=`basename $0`

if [ -z "${1}" ] || [ "" == "${1}" ] || [ -z "${2}" ] || [ "" == "${2}" ]; then
	echo " "
	echo "${ME}: usage: ${ME} sourceFolder gitlabInstallationCfgFolder "
	echo "${ME}: example: ${ME} /etc/pki/ca-trust/source/anchors/ /etc/gitlab/ "
	echo " "	
	exit -1
fi

GEM_PATH=$(find /opt/ | grep "embedded/bin/gem$")
RUBYGEMS_PATH=$(${GEM_PATH} which rubygems )
RUBYGEMS_FOLDER_PATH=${RUBYGEMS_PATH%".rb"}
CERTS_PATH="${RUBYGEMS_FOLDER_PATH}/ssl_certs/"

function others() 
{
	echo " "
	echo "Do the following: "
	echo " "
	echo "cd ${CERTS_PATH} "
	echo "wget https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/index.rubygems.org/GlobalSignRootCA.pem"
	echo " "
	echo "mv certFile.pem ${CERTS_PATH} "
	echo " "
}

cp -v ${1}/* ${2}/trusted-certs/


gitlab-ctl reconfigure

echo "systemctl restart gitlab-runsvdir.service ... "
systemctl restart gitlab-runsvdir.service
echo " "

