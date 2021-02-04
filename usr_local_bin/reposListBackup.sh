#!/bin/bash

ME="$(basename ${0})"
BACKUP_FILE="repositories_list.txt"

if [ -z "$1" ] || [ "" == "${1}" ]; then
	echo "${ME}: usage: ${ME} [backup|restore] "
	exit 0
fi

if [ "backup" == "${1}" ]; then

	GIT_CONFIGS_LIST=$(find . -name config | grep "git/config")

	echo "-+- Backup done at " > ${BACKUP_FILE}
	while read -r git_cfg_file ; do
		echo " " | tee -a ${BACKUP_FILE}
		echo " " | tee -a ${BACKUP_FILE}
		echo "-+- ${git_cfg_file} " | tee -a ${BACKUP_FILE}
		grep -i "\(remote\|url\)" ${git_cfg_file} | grep -vi "\(remote\s*=\s*\|fetch\s*=\s*\)" | tee -a ${BACKUP_FILE}
	done <<< ${GIT_CONFIGS_LIST}
fi

echo " " | tee -a ${BACKUP_FILE}

# DONE
