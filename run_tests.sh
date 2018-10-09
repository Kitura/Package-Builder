#!/bin/bash

##
# Copyright IBM Corporation 2016,2017,2018
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

set +e                   # do not exit immediately temporarily so we can generate a backtrace for any crash
ulimit -c unlimited      # enable core file generation
if [ -n "${CUSTOM_TEST_SCRIPT}" ] && [ -e ${projectFolder}/$CUSTOM_TEST_SCRIPT ]; then
  echo ">> Running custom test command: $(cat ${projectFolder}/$CUSTOM_TEST_SCRIPT)"
  source ${projectFolder}/$CUSTOM_TEST_SCRIPT
elif [ -e ${projectFolder}/.swift-test-macOS ] && [ "$osName" == "osx" ]; then
  echo ">> Running custom macOS test command: $(cat ${projectFolder}/.swift-test-macOS)"
  source ${projectFolder}/.swift-test-macOS
elif [ -e ${projectFolder}/.swift-test-linux ] && [ "$osName" == "linux" ]; then
  echo ">> Running custom Linux test command: $(cat ${projectFolder}/.swift-test-linux)"
  source ${projectFolder}/.swift-test-linux
else
  swift test
fi
TEST_EXIT_CODE=$?

if [[ $TEST_EXIT_CODE != 0 ]]; then
    if [ "$osName" == "osx" ]; then
        executable=`ls .build/debug/*Tests.xctest/Contents/MacOS/*Tests`
        coreFile=`ls -t /cores/* | head -n1`
    else
        executable=`ls .build/debug/*Tests.xctest`
        coreFile='./core'
    fi

    if [ ! -f "$coreFile" ]; then
        echo ">> Core file '$coreFile' not found."
    elif [ ! -x "$executable" ]; then
        echo ">> '$executable' not found or not an executable."
        lldb -c "$coreFile" --batch -o 'thread backtrace all' -o 'quit'
    else
        lldb "$executable" -c "$coreFile" --batch -o 'thread backtrace all' -o 'quit'
    fi

    exit $TEST_EXIT_CODE
fi

set -e
