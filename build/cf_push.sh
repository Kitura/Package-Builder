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
MAIN_MODULE_NAME=$(basename `find Sources Source srcs src -name "main.swift" -exec dirname {} \; 2> /dev/null`)

function warn_if_file_does_not_exit {
    if [ ! -f $1 ]; then
        echo WARNING: $1 does not exist
    fi
}

function exit_if_file_does_not_exit {
    if [ ! -f $1 ]; then
        error_and_exit $1 does not exist
    fi
}

function error_and_exit {
    echo ERROR: $1
    exit
}

function check_procfile {
    warn_if_file_does_not_exit Procfile

    if [  -f Procfile ]; then
        TYPE=$(cut -d: -f1 -s Procfile)
        COMMAND=$(cut -d: -f2 -s Procfile)

        if [ -z "$TYPE" ]; then
            error_and_exit "empty type in Procfile"
        fi

        if [ "$TYPE" != "web" ]; then
            error_and_exit "invalid type in Procfile: $TYPE"
        fi

        if [ -z "$COMMAND" ]; then
            error_and_exit "empty command in Procfile"
        fi

        if [ $COMMAND != $MAIN_MODULE_NAME ]; then
            error_and_exit "The command in Procfile ($COMMAND) does not match the executable module name ($MAIN_MODULE_NAME)"
        fi
    fi
}

exit_if_file_does_not_exit "Package.swift"
warn_if_file_does_not_exit ".swift-version"
warn_if_file_does_not_exit ".cfignore"

if [ -f $MANIFEST ]; then
    echo --- Perform Push by $MANIFEST
    check_procfile
    cf push
else
    echo --- No manifest.yaml found, pushing with default parameters
    echo --- To specify cf push parameters, create $MANIFEST and Procfile in this directory
    APP_NAME=$(basename `pwd`)
    PUSH_COMMAND="cf push ${APP_NAME} --no-manifest -b swift_buildpack -m 256M -i 1 --random-route -k 1024M -c ${MAIN_MODULE_NAME}"
    echo --- Pushing ${APP_NAME}
    echo --- ${PUSH_COMMAND}
    ${PUSH_COMMAND}
fi
