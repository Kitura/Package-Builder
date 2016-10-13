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
        PROCFILE_COMMAND=$(cut -d: -f2 -s Procfile | tr -d '[[:space:]]')

        if [ -z "$TYPE" ]; then
            error_and_exit "empty type in Procfile"
        fi

        if [ "$TYPE" != "web" ]; then
            error_and_exit "invalid type in Procfile: $TYPE"
        fi

        if [ -z "$PROCFILE_COMMAND" ]; then
            error_and_exit "empty command in Procfile"
        fi

        if [ ! -f "Sources/$PROCFILE_COMMAND/main.swift" ] && [ ! -f "Source/$PROCFILE_COMMAND/main.swift" ] && [ ! -f "src/$PROCFILE_COMMAND/main.swift" ] && [ ! -f "srcs/$PROCFILE_COMMAND/main.swift" ]; then
            echo "WARNING The command in Procfile ($PROCFILE_COMMAND) does not match an executable module"
            echo "No main.swift found in <Sources Directory>/${PROCFILE_COMMAND}/main.swift"
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
    if [ -z "${COMMAND}" ]; then
        if [ `find . -name "main.swift" | wc -l` -gt 1 ]; then
            echo "ERROR there are multiple main.swift files in the current package."
            echo "Either specify COMMAND in the make command line, e.g. make cfPush COMMAND=Foo"
            echo "or provide manifest.yaml with Procfile"
            exit 1
        fi
        COMMAND=$(basename `find . -name "main.swift" -exec dirname {} \;`)
    fi
    PUSH_COMMAND="cf push ${APP_NAME} --no-manifest -b swift_buildpack -m 256M -i 1 --random-route -k 1024M -c ${COMMAND}"
    echo --- Pushing ${APP_NAME}
    echo --- ${PUSH_COMMAND}
    ${PUSH_COMMAND}
fi
