#!/bin/bash

        for file in `find /opt | grep 'jre/lib/security/cacerts' `; do
                folder=`dirname ${file}`
                filename=`basename ${file}`

		echo "Found cacerts in ${file} ... "
                rm -fv ${folder}/old_${filename}
                mv -vf ${file} ${folder}/old_${filename}
                cd ${folder} && ln -s /etc/pki/java/cacerts .
                ls -la ${file}
		echo " "
		echo " "
        done


