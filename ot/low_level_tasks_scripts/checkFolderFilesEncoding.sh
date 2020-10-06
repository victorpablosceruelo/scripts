#!/bin/bash

if [ -z $1 ] || [ "$1" == "" ]; then
	echo "Please provide a folder path"
	exit -1
fi 

pushd $1

[ -f encodings_used.log ] && rm -fv encodings_used.log
[ -f encodings_list.log ] && rm -fv encodings_list.log

echo " "
echo " "
echo "- Saving results in encodings_used.log ... "
echo " "
for file in `find -type f `; do
	echo -n "   " 
	file -i ${file} | tee -a encodings_used.log ; 
done;
echo " "
echo " "
echo "- Encodings used: "
echo " "
cat encodings_used.log | awk -F ' ' '{ print $3 }' | awk -F '=' '{print $2}' | sed 's/ *$//g' >> encodings_list.log 

shownBefore=""
for encoding in `uniq encodings_list.log`; do
	for shown in shownBefore; do
		if [ "${shown}" == "${encoding}" ]; then
			continue
		fi
	done

	echo -n "   " 
	lines=$(grep ${encoding} encodings_used.log | wc -l )
	echo "${encoding}:  ${lines} occurrences "
done

echo " "
echo " "
popd

