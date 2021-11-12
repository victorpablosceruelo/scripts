#!/bin/bash

TAIL="`date +%Y%m%d_%H%M%S`"
CFG_FILE="${HOME}/.aws/credentials"
CFG_FILE_OLD="${CFG_FILE}_${TAIL}"
AWS_CACHE="${HOME}/.aws/cli/cache"
AWS_CACHE_OLD="${HOME}/.aws/cli/old_cache_${TAIL}"

echo "CFG File: ${CFG_FILE}"
echo "CFG File Backup: ${CFG_FILE_OLD} "
echo " "

if [ ! -f ${CFG_FILE} ]; then
       echo "Error: file does not exist: ${CFG_FILE} " 
       exit 1
fi

cp -vf ${CFG_FILE} ${CFG_FILE_OLD}
mv -vf ${AWS_CACHE} ${AWS_CACHE_OLD}

echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}"
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}"
echo "AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN}"

sed -i "s@aws_access_key_id *=.*\$@aws_access_key_id = ${AWS_ACCESS_KEY_ID}@g" ${CFG_FILE}
sed -i "s@aws_secret_access_key *=.*\$@aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}@g" ${CFG_FILE}
sed -i "s@aws_session_token *=.*\$@aws_session_token = ${AWS_SESSION_TOKEN}@g" ${CFG_FILE}


echo " "
echo " "
cat ${CFG_FILE}
echo " "

