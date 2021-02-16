#!/bin/bash

export DISPLAY=$(ip route|awk '/^default/{print $3}'):0.0

echo " "
echo "DISPLAY=$DISPLAY"
echo " "

