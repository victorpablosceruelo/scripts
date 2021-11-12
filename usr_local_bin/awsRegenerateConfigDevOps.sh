#!/bin/bash

CFG_FILE="${HOME}/.aws/config"

echo "CFG File: ${CFG_FILE}"
echo " "

echo "[default]" > ${CFG_FILE}
echo -n "aws_access_key_id = " >> ${CFG_FILE}
echo "${AWS_ACCESS_KEY_ID}" >> ${CFG_FILE}
echo -n "aws_secret_access_key = " >> ${CFG_FILE}
echo "${AWS_SECRET_ACCESS_KEY}" >> ${CFG_FILE}
echo -n "aws_session_token = " >> ${CFG_FILE}
echo "${AWS_SESSION_TOKEN}" >> ${CFG_FILE}
echo " " >> ${CFG_FILE}

echo "[acciona-tic-pro]" >> ${CFG_FILE}
echo "role_arn = arn:aws:iam::656345350587:role/role-tic-devops" >> ${CFG_FILE}
echo "source_profile = default" >> ${CFG_FILE}
echo "region=eu-west-1" >> ${CFG_FILE}
echo " " >> ${CFG_FILE}

cat ${CFG_FILE}


