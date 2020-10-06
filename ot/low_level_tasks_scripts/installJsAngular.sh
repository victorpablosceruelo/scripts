#!/bin/bash

set -x

killall node
killall node
killall node

echo " "
echo " - Cleaning... "
echo " "
rm -fRv /root/.npm /root/.npmrc /root/node_modules
# rm -fRv /usr/lib/node_modules/@angular /usr/lib/node_modules/@angular-devkit /usr/lib/node_modules/typescript

MODULES_TO_REMOVE=$(find /usr/lib/node_modules/ -mindepth 1 -maxdepth 1 | sed "s@/usr/lib/node_modules/@@g" | grep -v "^npm$")

for folderName in ${MODULES_TO_REMOVE}; do
	rm -fRv /usr/lib/node_modules/${folderName}
done

echo " " ; echo " " ; echo " "

NPM_JENKINS_PREFIX=$(su - jenkins -c 'npm prefix 2>&1')
if [ "" != "${NPM_JENKINS_PREFIX}" ]; then
	su - jenkins -c "rm -fRv ${NPM_JENKINS_PREFIX}/.npm ${NPM_JENKINS_PREFIX}/.npmrc ${NPM_JENKINS_PREFIX}/node_modules "
else
	NPM_JENKINS_PREFIX="/opt/jenkins-slave"
	su - jenkins -c "rm -fRv ${NPM_JENKINS_PREFIX}/.npm ${NPM_JENKINS_PREFIX}/.npmrc ${NPM_JENKINS_PREFIX}/node_modules "
fi

# su - jenkins -c 'npm uninstall angular-cli'
# su - jenkins -c 'npm uninstall @angular/cli'
# su - jenkins -c 'npm uninstall @angular-devkit/build-angular'

ls -la /root/node_modules
ls -la /usr/lib/node_modules/ 
echo " "
echo " "
echo " "

# NPM_OPTS="--registry https://artefactos-ic.scae.redsara.es/nexus/repository/registry_npmjs_org"
NPM_OPTS=""

npm config set proxy http://10.254.250.94:3128 
npm config set https-proxy http://10.254.250.94:3128 
# npm config set registry https://artefactos-ic.scae.redsara.es/nexus/repository/registry_npmjs_org
# npm config set _auth $(echo -n 'admin:c3f8fc4e93' | openssl base64)
# npm set strict-ssl false
npm config get cafile 
npm config set cafile "/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt"

echo " "
echo " "
echo " "

# npm ${NPM_OPTS} install -g npm
# @latest
npm cache clean --force
npm set audit false
npm uninstall -g angular-cli
npm uninstall -g @angular/cli
npm uninstall -g @angular-devkit/build-angular
npm cache clean --force
npm set audit true

echo " "
echo " "
echo " "

npm cache clean --force

npm config set proxy http://10.254.250.94:3128 
npm config set https-proxy http://10.254.250.94:3128

npm install -g @angular/cli@latest

echo " "
node -v 
npm -version
ng --version
echo " "

grep -i jenkins /etc/passwd
# mkdir -pv /opt/jenkins-slave
# chown -c jenkins:jenkins /opt/jenkins-slave/

echo " "
su - jenkins -c 'ng --version'
echo " "

