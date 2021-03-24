#!/bin/bash

ME="$(basename ${0})"
TMP_LOGS="/tmp/logs_${ME}"

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

echo " "
ALL_ORIGINS=$(grep "\[\s*remote\s*.*" .git/config | sed 's/\[\s*remote\s*"//g' | sed 's/"\s*\]//g')
echo " "

retVal=0
while read -r CURRENT_ORIGIN; do

	echo "git fetch -p ${CURRENT_ORIGIN}"
	git fetch -p ${CURRENT_ORIGIN}
	retVal=$?

done <<< ${ALL_ORIGINS}
# echo " "

if [ 0 -ne ${retVal} ]; then
	echo " "
	grep '\(\[\s*remote\s*"\|\s*url\s*=\s*\)' .git/config
fi

echo " "
echo "- Tracking all remote repositories branches... "
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
echo " "

echo "- Compressing and pruning... "
# git fetch -p
git gc --prune=now

rm -fv ${TMP_LOGS}
git branch | tee -a ${TMP_LOGS}
PREVIOUS_BRANCH=$(git branch | grep "* " | sed  "s/\* //g" )
echo "Current branch: ${PREVIOUS_BRANCH}"

rm -fv ${TMP_LOGS}
echo "git fetch --all ... "
git fetch --all 2>&1 >> ${TMP_LOGS}
cat ${TMP_LOGS}

rm -fv ${TMP_LOGS}
echo "git pull --all ... "
git pull --all 2>&1 >> ${TMP_LOGS}
cat ${TMP_LOGS}

ALL_REMOTE_BRANCHES="$(git branch -r)"
ALL_BRANCHES="$(git branch)"
while read -r CURRENT_BRANCH; do
	CURRENT_BRANCH=$(echo "${CURRENT_BRANCH}" | sed  "s/\* //g" )
	echo " "
	echo "Updating branch ${CURRENT_BRANCH}"
	
	UPDATE_FROM_REMOTE=$(echo "${ALL_REMOTE_BRANCHES}" | grep -e "${CURRENT_BRANCH}")
	RETVAL=$?
	if [ 0 -eq ${RETVAL} ]; then
		rm -fv ${TMP_LOGS} 
		git checkout ${CURRENT_BRANCH} 2>&1 >> ${TMP_LOGS}
		# echo "git fetch --all ... "
		# git fetch --all 2>&1 >> ${TMP_LOGS}
		# echo "git pull --all ... "
		# git pull --all 2>&1 >> ${TMP_LOGS}
		echo "git pull (current branch) ... "
		git pull
		echo "git pull --tags ... "
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

echo " "
echo "- Local tags removal if needed: "
REMOTE_TAGS=$(git ls-remote --tags origin | sed 's/\s\+/ /g' | cut -d " " -f 2 )
LOCAL_TAGS=$(git tag)

echo -n "Local  tags: "
while read -r LOCAL_TAG; do echo -n "${LOCAL_TAG} "; done <<< ${LOCAL_TAGS}
echo " "

echo -n "Remote tags: "
while read -r REMOTE_TAG; do echo -n "${REMOTE_TAG} "; done <<< ${REMOTE_TAGS}
echo " "

while read -r LOCAL_TAG; do
    remove_tag="true"
    while read -r REMOTE_TAG; do
	echo "${REMOTE_TAG}" | grep -q "refs/tags/${LOCAL_TAG}"
	grep_result=$?
	
	if [ 0 -eq ${grep_result} ]; then
	    echo "Tag ${LOCAL_TAG} found in remote: ${REMOTE_TAG}"
	    remove_tag="false"
	fi
    done <<< ${REMOTE_TAGS}
    
    if [ "true" == "${remove_tag}" ]; then
	echo "Removing local tag: ${LOCAL_TAG}"
	git tag -d ${LOCAL_TAG}
    fi
done <<< ${LOCAL_TAGS}

echo " "
echo "- Back to the branch we were working on... "
git checkout ${PREVIOUS_BRANCH}
echo " "
rm -fv ${TMP_LOGS}
git branch | tee -a ${TMP_LOGS} 
echo " "

