#!/bin/bash

# For tests:
# Activate curl debug: -v
# Available types of request: GET, PUT, DELETE
# set -x
# ANSWER=$(curl --insecure --ssl-no-revoke \
# 	      --header "Private-Token: wsVbcc9GSzCudwiTg-sG" \
# 	      --request GET "https://des-gitlab.scae.redsara.es/api/v4/groups" \
# 	      -d '{"all_available":"true", "owned":"false", "min_access_level":"false" }' \
# 	      --output ${TMP_FILE_GROUPS_QUERY}
#       )
# set +x
# 
# echo "$ANSWER" | python -m json.tool | pygmentize -l json
# curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>"

PYTHON_CMD=`which python`
if [ 0 -ne $? ]; then
	PYTHON_CMD=`which python2`
fi

${PYTHON_CMD} addGitLabProject.py $@
exit $?


