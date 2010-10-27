#!/usr/bin/env bash

########################################################################
# mysqldump.sh
# ----------------------------------------------------------------------
#
# @author Erwin Komaruloh <komaruloh@gmail.com>
#
# Manage calling to mysqldump to backup mysql dababase. Also compress
# and clear old backup files.
########################################################################

#
# execute()
#
# this function is a must. It act as an interface for the main script
# to access/run this script.
# 
function execute () {
    dump_database
}

#
# at this point, variables for connecting and fetching data should
# already 'declared' (evaled from it's config filename).
#
function dump_database() {
    DUMPED_TABLES=${TABLES[@]}
    COMMAND="$MYSQLDUMP $MYSQLDUMP_OPTIONS -u $DB_USERNAME --password=$DB_PASSWORD -h $DB_HOST $DB_NAME $DUMPED_TABLES"
    eval "$COMMAND > $DUMP_FILENAME_FULL"
    
    compress_dump
    clearing_old_backup
}

function compress_dump() {
    if [ $COMPRESSED_DUMP = 1 ]
        then            
            COMPRESSED_FILENAME_FULL="$COMPRESSED_DIRECTORY$DUMP_FILENAME"
            
            # choosing the compress method
            case $COMPRESSED_FORMAT in
                "tar.bz2"   )
                    COMPRESS_COMMAND="tar -C $DUMP_DIRECTORY -cjf $COMPRESSED_FILENAME_FULL.$COMPRESSED_FORMAT $DUMP_FILENAME"
                    ;;
                "tar.gzip"   )
                    COMPRESS_COMMAND="tar -C $DUMP_DIRECTORY -czf $COMPRESSED_FILENAME_FULL.$COMPRESSED_FORMAT $DUMP_FILENAME"
                    ;;
            esac

            if [ $BACKGROUND_COMPRESS = 1 ]
                then
                   COMPRESS_COMMAND="$COMPRESS_COMMAND &"
            fi
            
            eval "$COMPRESS_COMMAND"
            
            # warning, only clearing when dump is compressed 
            clearing_dump
    fi
}

function clearing_dump() {
    if [ $REMOVE_DUMP_FILE = 1 ]
        then
            # only remove dump when compressed file is exist
            if [ -e $DUMP_FILENAME_FULL ]
                then
                    REMOVE_COMMAND="rm -rf $DUMP_FILENAME_FULL"
                    eval "$REMOVE_COMMAND"
            fi
    fi
}

# Clears both compressed and sql dump file. Leaving between 
# $KEEPSAKE_DAYS until today
function clearing_old_backup() {
    if [ $REMOVE_OLD_DUMP=1 ]
        then
            # 4 is reduction for each variable used in prefix
            PREFIX_LENGTH=${#DB_HOST}+${#FILENAME_SEPARATOR}+${DB_NAME}+${FILENAME_SEPARATOR}

            # clearing dump (sql) file
            for FILE in $( ls ${DUMP_DIRECTORY} ); do
                if [ "${FILE:$PREFIX_LENGTH:8}" -lt  "${KEEPSAKE_DAYS}" ]
                    then
                        CLEAR_DUMP_COMMAND="rm -rf $DUMP_DIRECTORY$FILE"
                        eval "$CLEAR_DUMP_COMMAND"
                fi
            done

            # clearing compressed file
            for FILE in $( ls ${COMPRESSED_DIRECTORY} ); do
                #echo "$FILE :=: ${FILE:$PREFIX_LENGTH:8} :: ${KEEPSAKE_DAYS}"
                if [[ ${FILE:$PREFIX_LENGTH:8} -lt  ${KEEPSAKE_DAYS} ]]
                    then
                        CLEAR_COMPRESSED_COMMAND="rm -rf $COMPRESSED_DIRECTORY$FILE"
                        eval "$CLEAR_COMPRESSED_COMMAND"
                fi
            done
    fi
}
