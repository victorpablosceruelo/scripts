#!/bin/bash
set -o pipefail

ME="$(basename ${0})"
TMP_LOGS="/tmp/logs_${ME}"
TMP_UPGRADE_LOGS="/tmp/logs_${ME}_upgrade_$$"
TMP_REMOTE_TAGS="/tmp/logs_tags_${ME}_$$"

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

function rm_logs_files() {
	rm -f ${TMP_LOGS}
}

rm_logs_files
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
git branch 2>&1 >> ${TMP_LOGS}
PREVIOUS_BRANCH=$(git branch | grep "* " | sed  "s/\* //g" )
echo "Current branch: ${PREVIOUS_BRANCH}"

echo "git fetch --all ... "
git fetch --all 2>&1 >> ${TMP_LOGS}
# cat ${TMP_LOGS}

echo "git pull --all ... "
git pull --all 2>&1 >> ${TMP_LOGS}
# cat ${TMP_LOGS}

ALL_REMOTE_BRANCHES="$(git branch -r)"
ALL_BRANCHES="$(git branch)"
while read -r CURRENT_BRANCH; do
	CURRENT_BRANCH=$(echo "${CURRENT_BRANCH}" | sed  "s/\* //g" )
	# echo " "
	echo -n "Branch ${CURRENT_BRANCH}: "
	echo "Branch ${CURRENT_BRANCH}: " >> ${TMP_LOGS}
	
	UPDATE_FROM_REMOTE=$(echo "${ALL_REMOTE_BRANCHES}" | grep -e "${CURRENT_BRANCH}")
	RETVAL=$?
	if [ 0 -eq ${RETVAL} ]; then
	    rm -fv ${TMP_UPGRADE_LOGS} 2>&1 >> ${TMP_LOGS}
	    echo "git checkout && git pull && git pull --tags ... " | tee -a ${TMP_LOGS}

	    CHECKOUT_MSG=$(git checkout ${CURRENT_BRANCH} 2>&1)
	    echo "${CHECKOUT_MSG}" >> ${TMP_UPGRADE_LOGS}
	    CHECKOUT_MSG_CHECK=$(echo "${CHECKOUT_MSG}" | grep -e 'Your branch is up to date with')
	    RETVAL=$?
	    if [ 0 -ne ${RETVAL} ]; then
		git pull 2>&1 >> ${TMP_UPGRADE_LOGS}
		git pull --tags 2>&1 >> ${TMP_UPGRADE_LOGS}
	    else
		echo "${CHECKOUT_MSG}" | grep -v "Switched to branch"
	    fi
	    # cat ${TMP_LOGS}

	    # If branch does not exist remotely any more, unset it from local.
	    DO_UNSET=$(grep -e 'git branch --unset-upstream' ${TMP_UPGRADE_LOGS})
	    RETVAL=$?
	    if [ 0 -eq ${RETVAL} ]; then
		echo "- Unset upstream ..."
		git branch --unset-upstream 2>&1 | tee -a ${TMP_UPGRADE_LOGS}
	    fi
	    cat ${TMP_UPGRADE_LOGS} >> ${TMP_LOGS}
	    rm -f ${TMP_UPGRADE_LOGS} 2>&1 >> ${TMP_LOGS}
	else
	    echo " WARN: branch exists only locally. " | tee -a ${TMP_LOGS}
	fi
	echo "" | tee -a ${TMP_LOGS}
done <<< ${ALL_BRANCHES}

echo " "
echo "- Local tags removal if needed... "
git ls-remote --tags origin | sed 's/\s\+/ /g' | cut -d " " -f 2 > ${TMP_REMOTE_TAGS}
LOCAL_TAGS=$(git tag)

echo " " 2>&1 >> ${TMP_LOGS}
echo -n "Local  tags: " 2>&1 >> ${TMP_LOGS}
while read -r LOCAL_TAG; do echo -n "${LOCAL_TAG} " 2>&1 >> ${TMP_LOGS}; done <<< ${LOCAL_TAGS}
echo " " 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}

echo -n "Remote tags: " 2>&1 >> ${TMP_LOGS}
while read -r REMOTE_TAG; do echo -n "${REMOTE_TAG} " 2>&1 >> ${TMP_LOGS}; done < ${TMP_REMOTE_TAGS}
echo " " 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}

TAGS_LINKED=""
while read -r LOCAL_TAG; do
    if [ -z "${LOCAL_TAG}" ] || [ "" == "${LOCAL_TAG}" ]; then
	echo "WARN: Invalid local tag found: ${LOCAL_TAG}" >> ${TMP_LOGS}
    else
	remove_tag="true"

	grep -q "refs/tags/${LOCAL_TAG}" ${TMP_REMOTE_TAGS}
	grep_result=$?
	
	if [ 0 -eq ${grep_result} ]; then
	    TAGS_LINKED="${TAGS_LINKED} ${LOCAL_TAG} -> $(grep \"refs/tags/${LOCAL_TAG}\" ${TMP_REMOTE_TAGS})"
	    remove_tag="false"
	else
	    echo "Not found tag: ${LOCAL_TAG} "
	fi
    
	if [ "true" == "${remove_tag}" ]; then
	    echo "Removing local tag: ${LOCAL_TAG}" 2>&1 | tee -a ${TMP_LOGS}
	    git tag -d ${LOCAL_TAG}
	fi
    fi
done <<< ${LOCAL_TAGS}

echo "Tags ok: ${TAGS_LINKED}" 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}

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
git checkout ${PREVIOUS_BRANCH} 2>&1 >> ${TMP_LOGS}
echo " " 2>&1 >> ${TMP_LOGS}
git branch | tee -a ${TMP_LOGS} 2>&1 >> ${TMP_LOGS}
echo " "

