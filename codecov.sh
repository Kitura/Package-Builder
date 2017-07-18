#! /bin/bash

##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_BRANCH != "develop" && $TRAVIS_EVENT_TYPE != "cron" ]]; then
    echo "Not master, develop or cron build. Skipping code coverage generation"
    exit 0
fi

if [[ ${osName} != "osx" ]]; then
    echo "Not a macOS build. Hence, skipping code coverage generation."
    exit 0
fi

echo ">> Starting code coverage generation..."
uname -a

SDK=macosx
xcodebuild -version
xcodebuild -version -sdk $SDK
if [[ $? != 0 ]]; then
    exit 1
fi


CUSTOM_FILE="${projectFolder}/.swift-xcodeproj"

if [[ -f "$CUSTOM_FILE" ]]; then
  echo ">> Running custom xcodeproj command: $(cat $CUSTOM_FILE)"
  PROJ_OUTPUT=$(source "$CUSTOM_FILE")
else
  PROJ_OUTPUT=$(swift package generate-xcodeproj)
fi

PROJ_EXIT_CODE=$?
echo "$PROJ_OUTPUT"
if [[ $PROJ_EXIT_CODE != 0 ]]; then
    exit 1
fi

PROJECT="${PROJ_OUTPUT##*/}"
SCHEME=$(xcodebuild -list -project $PROJECT | grep --after-context=1 '^\s*Schemes:' | tail -n 1 | xargs)
TEST_CMD="xcodebuild -quiet -project $PROJECT -scheme $SCHEME -sdk $SDK -enableCodeCoverage YES -skipUnavailableActions test"

echo ">> Running: $TEST_CMD"
eval "$TEST_CMD"
if [[ $? != 0 ]]; then
    exit 1
fi

(( MODULE_COUNT = 0 ))
BASH_BASE="bash <(curl -s https://codecov.io/bash)"
for module in $(ls -F Sources/ 2>/dev/null | grep '/$'); do   # get only directories in "Sources/"
    module=${module%/}                                        # remove trailing slash
    BASH_CMD="$BASH_BASE -J '^${module}\$' -F '${module}'"
    (( MODULE_COUNT++ ))

    echo ">> Running: $BASH_CMD"
    eval "$BASH_CMD"
    if [[ $? != 0 ]]; then
        echo ">> Error running: $BASH_CMD"
        exit 1
    fi
done

if (( MODULE_COUNT == 0 )); then
    echo ">> Running: $BASH_BASE"
    eval "$BASH_BASE"
    if [[ $? != 0 ]]; then
        echo ">> Error running: $BASH_BASE"
        exit 1
    fi
fi
