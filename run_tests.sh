#!/bin/bash

set +e                   # do not exit immediately temporarily so we can generate a backtrace for any crash
ulimit -c unlimited      # enable core file generation
if [ -e ${TRAVIS_BUILD_DIR}/.swift-test-macOS ] && [ "$osName" == "osx" ]; then
  echo Running custom OSX test commands: `cat ${TRAVIS_BUILD_DIR}/.swift-test-macOS`
  source ${TRAVIS_BUILD_DIR}/.swift-test-macOS
elif [ -e ${TRAVIS_BUILD_DIR}/.swift-test-linux ] && [ "$osName" == "linux" ]; then
  echo Running custom Linux test commands: `cat ${TRAVIS_BUILD_DIR}/.swift-test-linux`
  source ${TRAVIS_BUILD_DIR}/.swift-test-linux
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
        echo "core file: '$coreFile' not found"
    elif [ ! -x "$executable" ]; then
        echo "'$executable': not found or not executable"
        lldb -c "$coreFile" --batch -o 'thread backtrace all' -o 'quit'
    else
        lldb "$executable" -c "$coreFile" --batch -o 'thread backtrace all' -o 'quit'
    fi

    exit $TEST_EXIT_CODE
fi

set -e
