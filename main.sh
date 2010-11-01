#!/usr/bin/env bash

# directories
cd `dirname $0`
BASE_DIRECTORY=`pwd`/
CONFIG_DIRECTORY=${BASE_DIRECTORY}config/
LIB_DIRECTORY=${BASE_DIRECTORY}lib/

MAIN_CONFIG_FILE=${CONFIG_DIRECTORY}main.config
LIB_CONFIG_FILE_READER=${LIB_DIRECTORY}parseconfig.sh

# load the config reader
source ${LIB_CONFIG_FILE_READER}
# read the main config 
readconf ${MAIN_CONFIG_FILE}  "main"

#echo ${BASE_DIRECTORY}
#echo ${CONFIG_DIRECTORY}
#echo ${LIB_DIRECTORY}
#echo ${SCRIPT_DIRECTORY}
#echo ${DUMP_DIRECTORY}
#echo ${LOG_DIRECTORY}
#echo ${#SCRIPT_EXTENSION}

function runscript() {
    FILE=$1
    # bypassing filename started with "test" for development purpose.
    if [ ${FILE:0:4} = "test" ]
        then
            continue
    fi

    # looking for the basename for the script to identify the config
    # file and log file used.
    FILENAME_LENGTH=${#FILE}
    let FILENAME_BASE_LENGTH=$FILENAME_LENGTH-${#SCRIPT_EXTENSION}
    FILENAME_BASE=${FILE:0:${FILENAME_BASE_LENGTH}}

    CONFIG_FILE=${CONFIG_DIRECTORY}${FILENAME_BASE}${CONFIG_EXTENSION}
    SCRIPT_FILE=${SCRIPT_DIRECTORY}${FILENAME_BASE}${SCRIPT_EXTENSION}

    readconf ${CONFIG_FILE} ${DEFAULT_TAG}

    for TAG in ${TAGS[@]} ; do
        #echo "Reading $CONFIG_FILE for $TAG"
        readconf ${CONFIG_FILE} ${TAG}

        #echo "Executing $SCRIPT_FILE"
        source ${SCRIPT_FILE}
        execute
    done
}

for FILE in $( ls ${SCRIPT_DIRECTORY} ); do
    runscript ${FILE}
done

# an empty function to be replaced by an 'init' function in the script
# file with the same name
function execute() {
    echo ''
}
