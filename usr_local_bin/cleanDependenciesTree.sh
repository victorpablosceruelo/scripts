#!/bin/bash

FILE=$1

if [ -z "$1" ] || [ "" == "$1" ]; then
	exit 1
fi

rm -fv ${FILE}.tmp* ${FILE}.out*

grep -vi "maven-dependency-plugin:.*:tree" ${FILE} > ${FILE}.tmp1
grep -iv '\-\+\{4\}' ${FILE}.tmp1 > ${FILE}.tmp2
grep -iv '\.\+\{4\}' ${FILE}.tmp2 > ${FILE}.tmp3
# grep -vi "(\-){4,+}" ${FILE}.tmp1 > ${FILE}.tmp2
sed -i 's@@@g' ${FILE}.tmp3
# PREVIOUS: $'s@\\033@@g' ${FILE}.tmp2
sed -i 's@1;34mINFO@@g' ${FILE}.tmp3
sed -i 's@1;33mWARNING@@g' ${FILE}.tmp3
sed -i 's@\[\+[[:alnum:]]\+\]\+@@g' ${FILE}.tmp3
# 's@\[\\[\|[:alnum:]\]\+' ${FILE}.tmp2
# cp -vf ${FILE}.tmp3 ${FILE}.tmp4
grep -vi "^\(Downloading \|.*Building \|.*Reactor Build Order\|\ *Could not transfer\|\ *Scanning for projects\|\ *Failure to transfer\|.*Reactor Summary for\|\ *Finished at\|.*BUILD SUCCESS\|\ *Total time\)" $FILE.tmp3 > ${FILE}.tmp4
# grep -i "^(\ )\+\[\-\|+\|\ \||\]\+" ${FILE}.tmp4 > ${FILE}.tmp5
grep -i "^\[\-\|+\|\ \||\]\+" ${FILE}.tmp4 > ${FILE}.tmp5

# rm -f ${FILE}.tmp1 ${FILE}.tmp2 ${FILE}.tmp3
# mv -fv ${FILE}.tmp $FILE

# sed -i "s/^[ESC[1;34mINFOESC[m]//g" $FILE
# sed -i "s/^.*]//g" $FILE
# sed -i "s/^\^[\^[]//g" $FILE

cp -vf ${FILE}.tmp5 ${FILE}.tmp6
#sed -i 's@\^\[@@g' ${FILE}.tmp
sed -i "s@^(\[\+\|\-\||\|\ \])\+@@g" ${FILE}.tmp6
sed -i 's@^\ *\+\ *@@g' ${FILE}.tmp6
sed -i 's@^\+@@g' ${FILE}.tmp6
sed -i 's@^\\@@g' ${FILE}.tmp6
sed -i 's@^\ @@g' ${FILE}.tmp6
sed -i 's@:compile@@g' ${FILE}.tmp6
sed -i 's@:runtime@@g' ${FILE}.tmp6
sed -i 's@:test@@g' ${FILE}.tmp6


# head -n 50 ${FILE}.tmp
sort --output ${FILE}.tmp7 ${FILE}.tmp6
uniq ${FILE}.tmp7 ${FILE}.tmp8
# rm -fv ${FILE}.tmp2

echo " "; echo " ";

mv -vf ${FILE}.tmp8 ${FILE}.out
# cat ${FILE}.out

head -n 20 ${FILE}.out
echo " "; echo " ";

# 

