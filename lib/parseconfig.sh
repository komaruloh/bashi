#!/usr/bin/env bash

########################################################################
# parseconfig.sh
# ----------------------------------------------------------------------
#
# @author Erwin Komaruloh <komaruloh@gmail.com>
# @original_author Michael Klier <chi@chimeric.de>
# @link http://www.chimeric.de/blog/2007/1122_parsing_simple_config_files_in_bash
#
# This work is based on Michael Klier <chi@chimeric.de> work on 
#     parseconfig.sh 
# <http://www.chimeric.de/blog/2007/1122_parsing_simple_config_files_in_bash>
########################################################################

########################################################################
# readconf() 
#    arguments (positional parameters) : 
#       1. File name of the config
#       2. The block which to read
# 
# readlines()
#    arguments (positional parameters) : 
#       1. File name of the config
#       2. The block which to read
# 
# readblock()
#    arguments (positional parameters) : 
#       1. Line of config file to be parse
#       2. The block which to read
########################################################################

######################################################################## 
# 2010-10-16 : 
#   - Breaks the readconf() into three separate functions (readlines(), 
#     readblock(), and readconf() it self) to acomodate reading multiple
#     block (used to read default).
# 2010-10-16 : 
#   - Add the ability to read config file passed as argument
########################################################################

# the name of default tag, just in case users provide different default 
# tag 
default="default"

function readconf() {
    # takes the third argument as default tag
    if [ -n "$3" ]  
    then 
        default=$3 
    fi
    
    # read default first
    readlines $1 $default
    # then override necesary values
    readlines $1 $2
}

# read file into lines
function readlines() {
    match=0
 
    while read line; do
        # skip comments
        [[ ${line:0:1} == "#" ]] && continue
 
        # skip empty lines
        [[ -z "$line" ]] && continue

        readblock "${line}" "$2"
 
 
    done < "$1"

}

# parse each line
function readblock() {
    # still no match? lets check again
    if [ $match == 0 ]; then

        # do we have an opening tag ?
        if [[ ${1:$((${#1}-1))} == "{" ]]; then

            # strip "{"
            group=${1:0:$((${#1}-1))}
            # strip whitespace
            group=${group// /}

            # do we have a match ?
            if [[ "$group" == "$2" ]]; then
                match=1
                #continue
            fi

            #continue
        fi

    # found closing tag after config was read - exit loop
    elif [[ ${1:0} == "}" && $match == 1 ]]; then
        break
    # got a config line eval it
    else
        eval $1
    fi

}
