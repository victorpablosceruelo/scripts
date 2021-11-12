#!/bin/bash

TARGET="/opt/software-packages"

# AWS cli version 1
# curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "${TARGET}/awscli-bundle.zip"
# pushd ${TARGET}
# unzip awscli-bundle.zip -d awscli-bundle
# popd
# ${TARGET}/awscli-bundle/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# AWS cli version 2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "${TARGET}/awscli_v2.zip"
pushd ${TARGET}
unzip awscli_v2.zip -d awscli_v2
popd
${TARGET}/awscli_v2/aws/install

