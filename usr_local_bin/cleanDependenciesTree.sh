#!/bin/bash

FILE=$1

if [ -z "$1" ] || [ "" == "$1" ]; then
	exit 1
fi

grep -vi "^\(Downloading \|\ *Could not transfer\|\ *Failure to transfer\|.*Reactor Summary for\|\ *Finished at\)" $FILE > ${FILE}.tmp1
grep -vi "maven-dependency-plugin:.*:tree" ${FILE}.tmp1 > ${FILE}.tmp2
grep -vi "\-\-\-\-\-" ${FILE}.tmp2 > ${FILE}.tmp3
grep -i "^\[+\|\-\||\|\ \]" ${FILE}.tmp3 > ${FILE}

rm -fv ${FILE}.tmp1 ${FILE}.tmp2 ${FILE}.tmp3
# mv -fv ${FILE}.tmp $FILE

# sed -i "s/^[ESC[1;34mINFOESC[m]//g" $FILE
# sed -i "s/^.*]//g" $FILE
# sed -i "s/^\^[\^[]//g" $FILE

cp -vf ${FILE} ${FILE}.tmp
sed -i "s@^(\[\+\|\-\||\|\ \])\+@@g" ${FILE}.tmp
sed -i 's@^\ *\+\ *@@g' ${FILE}.tmp
sed -i 's@^\+@@g' ${FILE}.tmp
sed -i 's@^\\@@g' ${FILE}.tmp
sed -i 's@^\ @@g' ${FILE}.tmp
sed -i 's@:compile@@g' ${FILE}.tmp
sed -i 's@:runtime@@g' ${FILE}.tmp
sed -i 's@:test@@g' ${FILE}.tmp


# head -n 50 ${FILE}.tmp
sort --output ${FILE}.tmp2 ${FILE}.tmp
uniq ${FILE}.tmp2 ${FILE}.tmp
rm -fv ${FILE}.tmp2

echo " "; echo " "; echo " "; echo " "; echo " ";

mv -vf ${FILE}.tmp ${FILE}.out
# cat ${FILE}.out

