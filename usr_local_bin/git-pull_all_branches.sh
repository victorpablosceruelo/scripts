#!/bin/bash

# From https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches

echo " "
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
echo " "

git fetch --all
git pull --all

echo "Done. Results: " 
echo " "
git branch
echo " "

