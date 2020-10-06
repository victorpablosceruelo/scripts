#!/bin/bash

ME="$(basename $0 )"
DIRNAME="$(dirname $0)"

# Red Hat
which rpm
if [ 0 -ne $? ]; then

	echo "Not a Red Hat or variant OS. Not found rpm."

else

	echo "Red Hat or variant OS."

	which dnf
	if [ 0 -ne $? ]; then
        	OS_INSTALLER="yum"
	else
        	OS_INSTALLER="dnf"
	fi

	numLines=$(rpm -qa ca-certificates | wc -l)
	numLinesInt=$(( numLines + 0))
	echo "Amount of packages named ca-certificates: ${numLines} ( ${numLinesInt} ) "
	if [ 0 -eq ${numLinesInt} ]; then
		echo "Installing ca-certificates ... "
		${OS_INSTALLER} install -y ca-certificates
	else
		echo "Package ca-certificates seems to be installed: "
		echo " "
		rpm -qa ca-certificates
		echo " "
		${OS_INSTALLER} list installed | grep -i "ca-certificates"
		echo " "	
	fi


	TARGET_FOLDER="/etc/pki/ca-trust/source/anchors/"
	SOURCE_FOLDER="${DIRNAME}/knownCertificates/"

	for certFile in $(find ${DIRNAME}/knownCertificates/ -maxdepth 1 -type f ); do
		cp -vf ${certFile} ${TARGET_FOLDER}
	done

	echo "Certificates installed in $(hostname):"
	find ${TARGET_FOLDER} -maxdepth 1 -type f 
	echo " "
	echo "Updating ca-trust database(s) ... "

	update-ca-trust force-enable
	update-ca-trust extract

	${DIRNAME}/install_to_other_jvms.sh
fi

# Debian/Ubuntu
which update-ca-certificates
if [ 0 -ne $? ]; then

	echo "Not a Debian or variant OS: Not found update-ca-certificates."

else

	echo "Debian or variant OS"

	TARGET_FOLDER="/usr/local/share/ca-certificates/"
	SOURCE_FOLDER="${DIRNAME}/knownCertificates/"

	for certFile in $(find ${DIRNAME}/knownCertificates/ -maxdepth 1 -type f ); do
                cp -vf ${certFile} ${TARGET_FOLDER}
        done

fi

echo "Done."
echo " "

${DIRNAME}/checkHostCertificateWithRuby.sh gitlab-ic.scae.redsara.es
echo " "
