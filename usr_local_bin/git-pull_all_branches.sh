#!/bin/bash

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

echo " "
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
echo " "

PREVIOUS_BRANCH=$(git branch | grep "* " | sed  "s/\* //g" )
echo "Current branch: ${PREVIOUS_BRANCH}"

git branch | while read CURRENT_BRANCH; do
	CURRENT_BRANCH=$(echo "${CURRENT_BRANCH}" | sed  "s/\* //g" )
	echo " "
	echo "${CURRENT_BRANCH}"
	git checkout ${CURRENT_BRANCH}
	git fetch --all
	git pull --all
	git pull --tags
done

git checkout ${PREVIOUS_BRANCH}

echo "Done. Results: "

echo " "
git branch
echo " "

