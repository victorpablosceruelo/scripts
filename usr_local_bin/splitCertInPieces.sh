#!/bin/bash

ME=$(basename $0)

if [ -z "$1" ] || [ "" == "$1" ]; then
	echo "${ME}: usage: ${ME} inputFileName "
	exit 0
fi

inputFileName="$1"
outputFilePrefix="cert"

rm -fv ${outputFilePrefix}_*.cer

index=0
fileNamePartS=""
fileNamePartI=""
fileName=""
hasBegan=""
hasEnded=""

while IFS= read -r line
do
	# echo $line
	if [ -z "${fileNamePartS}" ] || [ "" == "${fileNamePartS}" ] || [ -z "${fileNamePartI}" ] || [ "" == "${fileNamePartI}" ]; then
		certNameS=$(echo $line | grep -ie ".*s:.*CN[\ ]*=.*" )
		if [ ! -z "${certNameS}" ] && [ "" != "${certNameS}" ]; then
			echo "${ME}: certNameS: $certNameS"
			
			let "index++"
			fileNameTmp=$(echo $certNameS | sed 's|.*s:.*CN[\ ]*=[\ ]*||g')
			fileNameTmp=$(echo $fileNameTmp | sed 's|\ |_|g')
			fileNamePartS=$(echo $fileNameTmp | sed 's|\.|_|g')
			fileName="${outputFilePrefix}_${index}_${fileNamePartS}_by_${fileNamePartI}.cer"
			echo "${ME}: fileName(S) n.${index}: ${fileName}"
		fi
		
		certNameI=$(echo $line | grep -ie "[\ ]*i:.*CN[\ ]*=.*" )
		if [ ! -z "${certNameI}" ] && [ "" != "${certNameI}" ]; then
			echo "${ME}: certNameI: $certNameI"
			
			let "index++"
			fileNameTmp=$(echo $certNameI | sed 's|.*i:.*CN[\ ]*=[\ ]*||g')
			fileNameTmp=$(echo $fileNameTmp | sed 's|\ |_|g')
			fileNamePartI=$(echo $fileNameTmp | sed 's|\.|_|g')
			fileName="${outputFilePrefix}_${index}_${fileNamePartS}_by_${fileNamePartI}.cer"
			echo "${ME}: fileName(I) n.${index}: ${fileName}"
		fi
	else
		if [ ! -z "${fileName}" ] && [ "" != "${fileName}" ]; then
			if [ -z "${hasBegan}" ] || [ "" == "${hasBegan}" ]; then
				hasBegan=$(echo $line | grep -ie "[-]*BEGIN CERTIFICATE[-]*")
	
				if [ ! -z "${hasBegan}" ] && [ "" != "${hasBegan}" ]; then
					echo "${line}" >> $fileName
				fi
			else
			
				if [ ! -z "${hasBegan}" ] && [ "" != "${hasBegan}" ]; then
					hasEnded=$(echo $line | grep -ie "[-]*END CERTIFICATE[-]*")
				
					if [ ! -z "${hasEnded}" ] && [ "" != "${hasEnded}" ]; then
				
						echo "${line}" >> $fileName
				
						fileNamePartS=""
						fileNamePartI=""
						fileName=""
						hasBegan=""
					fi
				fi
				
				if [ ! -z "${hasBegan}" ] && [ "" != "${hasBegan}" ]; then
					echo "${line}" >> $fileName
				fi
				
			fi
		fi
	fi


done < "$inputFileName"

echo "Removing dupplicates... "
for fileName1 in ${outputFilePrefix}_*; do
	for fileName2 in ${outputFilePrefix}_*; do
		if [ "${fileName1}" != "${fileName2}" ] && [ -f ${fileName1} ] && [ -f ${fileName2} ]; then
			diffResult=$(diff -q $fileName1 $fileName2)
			if [ $? -eq 0 ]; then
				echo "${ME}: diffResult: ${diffResult}"
				rm -fv $fileName2
			fi
		fi
	done
done

echo "Files generated: "
ls -la ${outputFilePrefix}_*
