#!/bin/bash

#/**
#* Copyright IBM Corporation 2016
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#**/

MANIFEST=manifest.yml

function warn_if_file_does_not_exit {
    if [ ! -f $1 ]; then
        echo WARNING: $1 does not exist
    fi
}

function exit_if_file_does_not_exit {
    if [ ! -f $1 ]; then
        error_and_exit "$1 does not exist"
    fi
}

function error_and_exit {
    echo ERROR: $1
    exit
}

function check_procfile {

    if [ ! -f Procfile ]; then
        COMMAND_LINE=$(grep "command:" manifest.yml)
        if [ -z "${COMMAND_LINE}" ]; then
           echo "ERROR No Procfile exists and no command attribute appears in manifest.yml"
           echo "Please add Procfile or add command attribute to manifest.yml"
           exit 1
        fi
    else
        COMMAND_LINE=$(head -1 Procfile)
        TYPE=$(cut -d: -f1 -s Procfile)


        if [ -z "$TYPE" ]; then
            error_and_exit "empty type in Procfile"
        fi

        if [ "$TYPE" != "web" ]; then
            error_and_exit "invalid type in Procfile: $TYPE"
        fi

    fi

    SPECIFIED_COMMAND=$(echo ${COMMAND_LINE} | cut -d: -f2 -s | sed -e 's/^[[:space:]]*//' | cut -d' ' -f1 -s)

    if [ -z "$SPECIFIED_COMMAND" ]; then
        error_and_exit "empty command in Procfile/manifest.yml"
    fi

    if [ ! -f "Sources/$SPECIFIED_COMMAND/main.swift" ] && [ ! -f "Source/$SPECIFIED_COMMAND/main.swift" ] && [ ! -f "src/$SPECIFIED_COMMAND/main.swift" ] && [ ! -f "srcs/$SPECIFIED_COMMAND/main.swift" ]; then
        echo "WARNING The command ($SPECIFIED_COMMAND) in Procfile/manifest.yml does not match an executable module"
        echo "No main.swift found in <Sources Directory>/${SPECIFIED_COMMAND}/main.swift"
    fi
}

exit_if_file_does_not_exit "Package.swift"
warn_if_file_does_not_exit ".swift-version"
warn_if_file_does_not_exit ".cfignore"

exit_if_file_does_not_exit "manifest.yml"

check_procfile
cf push
