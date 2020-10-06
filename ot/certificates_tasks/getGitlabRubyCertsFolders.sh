#!/bin/bash

ME=$(basename ${0})

if [ -z "${1}" ] || [ "" == "${1}" ]; then
	echo " "
	echo "${ME}: Please provide server name."
	echo "${ME}: usage: ${ME} https://redmine-ic.scae.redsara.es "
	echo " "
	HOST="https://redmine-ic.scae.redsara.es"
else
	HOST="${1}"
fi

# RUBY_CMD="/opt/gitlab/embedded/bin/ruby"
RUBY_CMD="./ruby.sh"

cert_file=$(${RUBY_CMD} -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE' )
echo "Certificates file: $cert_file "
certs_folder=$(${RUBY_CMD} -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_DIR' )
echo "Certificates folder: $certs_folder "


CMD="${RUBY_CMD} -ropen-uri -e 'eval open(\"${HOST}\").read'"
echo ${CMD}
# $($CMD)

echo " "

CMD="${RUBY_CMD} -rnet/http -e \"Net::HTTP.get URI('${HOST}')\""
echo ${CMD}



