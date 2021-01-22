#!/bin/bash

ME="$(basename ${0})"
TMP_LOGS="/tmp/logs_${ME}"

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

echo " "
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
echo " "

git fetch -p
git gc --prune=now

git branch
PREVIOUS_BRANCH=$(git branch | grep "* " | sed  "s/\* //g" )
echo "Current branch: ${PREVIOUS_BRANCH}"

ALL_REMOTE_BRANCHES="$(git branch -r)"
ALL_BRANCHES="$(git branch)"
while read -r CURRENT_BRANCH; do
	CURRENT_BRANCH=$(echo "${CURRENT_BRANCH}" | sed  "s/\* //g" )
	echo " "
	echo "${CURRENT_BRANCH}"
	
	UPDATE_FROM_REMOTE=$(echo "${ALL_REMOTE_BRANCHES}" | grep -e "${CURRENT_BRANCH}")
	RETVAL=$?
	if [ 0 -eq ${RETVAL} ]; then
		rm -fv ${TMP_LOGS} 
		git checkout ${CURRENT_BRANCH} 2>&1 >> ${TMP_LOGS}
		git fetch --all 2>&1 >> ${TMP_LOGS}
		git pull --all 2>&1 >> ${TMP_LOGS}
		git pull --tags 2>&1 >> ${TMP_LOGS}
		cat ${TMP_LOGS}

		DO_UNSET=$(grep -e 'git branch --unset-upstream' ${TMP_LOGS})
		RETVAL=$?
		if [ 0 -eq ${RETVAL} ]; then
			echo "- Unset upstream ..."
			git branch --unset-upstream
		fi
	fi
done <<< ${ALL_BRANCHES}

git checkout ${PREVIOUS_BRANCH}

echo "Done. Results: "

echo " "
git branch
echo " "

