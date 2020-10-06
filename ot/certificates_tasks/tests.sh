#!/bin/bash

echo QUIT | \
openssl s_client -showcerts -connect ${1}:${2} | \
awk '/-----BEGIN CERTIFICATE-----/ {p=1}; p; /-----END CERTIFICATE-----/ {p=0}' 
# --

