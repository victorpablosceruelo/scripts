#!/bin/bash

ME="$(basename ${0})"
TMP_LOGS="/tmp/logs_${ME}"

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

function rm_logs_files() {
	rm -f ${TMP_LOGS}
}

echo " "
ALL_ORIGINS=$(grep "\[\s*remote\s*.*" .git/config | sed 's/\[\s*remote\s*"//g' | sed 's/"\s*\]//g')
echo " "

retVal=0
while read -r CURRENT_ORIGIN; do

	echo "- Fetching: git fetch -p ${CURRENT_ORIGIN}"
	git fetch -p ${CURRENT_ORIGIN}
	retVal=$?

done <<< ${ALL_ORIGINS}
# echo " "

if [ 0 -ne ${retVal} ]; then
	echo " "
	grep '\(\[\s*remote\s*"\|\s*url\s*=\s*\)' .git/config
fi

echo " "
echo "- Tracking all remote repositories branches... " 2>&1 | tee -a ${TMP_LOGS}
git branch -r | grep -v '\->' | while read remote; do
    echo -n "git branch --track ${remote#origin/} $remote ... ";
    git branch --track "${remote#origin/}" "$remote" 2>&1 >> ${TMP_LOGS};
done
echo " "

echo "- Compressing and pruning... "
# git fetch -p
git gc --prune=now 2>&1 >> ${TMP_LOGS}

echo " "
echo "- Current local branches... "
rm_logs_files
git branch 2>&1 >> ${TMP_LOGS}
PREVIOUS_BRANCH=$(git branch | grep "* " | sed  "s/\* //g" )
echo "Current branch: ${PREVIOUS_BRANCH}"

rm_logs_files
echo "git fetch --all ... "
git fetch --all 2>&1 >> ${TMP_LOGS}
# cat ${TMP_LOGS}

rm_logs_files
echo "git pull --all ... "
git pull --all 2>&1 >> ${TMP_LOGS}
# cat ${TMP_LOGS}

ALL_REMOTE_BRANCHES="$(git branch -r)"
ALL_BRANCHES="$(git branch)"
while read -r CURRENT_BRANCH; do
	CURRENT_BRANCH=$(echo "${CURRENT_BRANCH}" | sed  "s/\* //g" )
	# echo " "
	echo -n "Branch ${CURRENT_BRANCH}: "
	
	UPDATE_FROM_REMOTE=$(echo "${ALL_REMOTE_BRANCHES}" | grep -e "${CURRENT_BRANCH}")
	RETVAL=$?
	if [ 0 -eq ${RETVAL} ]; then
	    rm_logs_files
	    echo -n "checkout && git pull && git pull --tags ... "
	    git checkout ${CURRENT_BRANCH} 2>&1 >> ${TMP_LOGS}
	    git pull 2>&1 >> ${TMP_LOGS}
	    git pull --tags 2>&1 >> ${TMP_LOGS}
	    # cat ${TMP_LOGS}

	    # If branch does not exist remotely any more, unset it from local.
	    DO_UNSET=$(grep -e 'git branch --unset-upstream' ${TMP_LOGS})
	    RETVAL=$?
	    if [ 0 -eq ${RETVAL} ]; then
		echo "- Unset upstream ..."
		git branch --unset-upstream
	    fi
	else
	    echo ""
	fi
done <<< ${ALL_BRANCHES}

echo " "
echo -n "- Local tags removal if needed... "
echo -n "."
REMOTE_TAGS=$(git ls-remote --tags origin | sed 's/\s\+/ /g' | cut -d " " -f 2 )
LOCAL_TAGS=$(git tag)

echo -n "."
echo " " 2>&1 >> ${TMP_LOGS}
echo -n "Local  tags: " 2>&1 >> ${TMP_LOGS}
while read -r LOCAL_TAG; do echo -n "${LOCAL_TAG} " 2>&1 >> ${TMP_LOGS}; done <<< ${LOCAL_TAGS}
echo " " 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}

echo -n "."
echo -n "Remote tags: " 2>&1 >> ${TMP_LOGS}
while read -r REMOTE_TAG; do echo -n "${REMOTE_TAG} " 2>&1 >> ${TMP_LOGS}; done <<< ${REMOTE_TAGS}
echo " " 2>&1 >> ${TMP_LOGS}

TAGS_LINKED=""
while read -r LOCAL_TAG; do
    echo -n "."
    remove_tag="true"
    while read -r REMOTE_TAG; do
	echo "${REMOTE_TAG}" | grep -q "refs/tags/${LOCAL_TAG}"
	grep_result=$?
	
	if [ 0 -eq ${grep_result} ]; then
	    TAGS_LINKED="${TAGS_LINKED} ${LOCAL_TAG} -> ${REMOTE_TAG}"
	    remove_tag="false"
	fi
    done <<< ${REMOTE_TAGS}
    
    if [ "true" == "${remove_tag}" ]; then
	echo "Removing local tag: ${LOCAL_TAG}" 2>&1 | tee -a ${TMP_LOGS}
	git tag -d ${LOCAL_TAG}
    fi
done <<< ${LOCAL_TAGS}

echo "Tags ok: ${TAGS_LINKED}" 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}
echo " "

echo " "
echo "- Local branches not tracked in remote repositories branches... " 2>&1 | tee -a ${TMP_LOGS}
git branch | sed 's@^\ *\**\ *@@g' | while read branchName; do
    branchExists=$(git branch -r | sed 's@^\ *\**\ *@@g' | grep -i "$branchName")
    if [ -z "${branchExists}" ] || [ "" == "${branchExists}" ]; then
	echo "WARN: Branch exists only locally: ${branchName}"
    fi
done
echo " "


echo "- Back to the branch we were working on...( ${PREVIOUS_BRANCH} ) "
git checkout ${PREVIOUS_BRANCH}
echo " "
rm_logs_files
git branch | tee -a ${TMP_LOGS} 
echo " "

