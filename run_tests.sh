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
  echo ">> Running test command: swift test ${SWIFT_TEST_ARGS}"
  swift test ${SWIFT_TEST_ARGS}
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

# Run Kitura tests with the current Kitura-net or Kitura-NIO branch, if asked for
if [ -n "${RUN_KITURA_TESTS}" ]; then
    PROJECT_DIR=`pwd`

    # If we are to test Kitura with Kitura-NIO, we'd need to set the KITURA_NIO env var
    NET_PACKAGE=$(pwd | rev | cut -d'/' -f1 | rev)
    if [ "${NET_PACKAGE}" == "Kitura-NIO" ]; then
        echo ">> Setting KITURA_NIO=1"
        export KITURA_NIO=1
    fi
    echo ">> cd ../ && git clone https://github.com/IBM-Swift/Kitura && cd Kitura"
    cd ../ && git clone https://github.com/IBM-Swift/Kitura && cd Kitura
    echo ">> swift build"
    swift build
    echo ">> swift package edit $NET_PACKAGE --path $PROJECT_DIR"
    swift package edit $NET_PACKAGE --path $PROJECT_DIR
    echo ">> swift package edit returned $?"
    echo ">> swift test"
    swift test
    TEST_EXIT_CODE=$?

    if [[ $TEST_EXIT_CODE != 0 ]]; then
        exit $TEST_EXIT_CODE
    fi

    # On macOS, swiftlint will run after this script. We make sure we exit this script from the right location
    cd $PROJECT_DIR 
fi

set -e
