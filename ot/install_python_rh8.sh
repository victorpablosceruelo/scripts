#!/bin/bash

TO_REMOVE=$(dnf list installed | grep el7 | cut -d ' ' -f 1 | grep -v '\(postgresql\|postgresql\)' | xargs echo )

dnf remove ${TO_REMOVE}

dnf --allowerasing install python2-requests.noarch python2-urllib3.noarch


