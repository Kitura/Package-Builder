#! /bin/bash

if [[ $TRAVIS && $TRAVIS_EVENT_TYPE != "cron" ]]; then
    echo "Not cron build. Skipping code coverage generation"
    exit 0
fi

if [[ $TRAVIS && $TRAVIS_OS_NAME != "osx" ]]; then
    echo "Not osx build. Skipping code coverage generation"
    exit 0
fi

echo "Starting code coverage generation"
uname -a

SDK=macosx
xcodebuild -version
xcodebuild -version -sdk $SDK
if [[ $? != 0 ]]; then
    exit 1
fi

PROJ_CMD="swift package generate-xcodeproj"
echo "Running $PROJ_CMD"
PROJ_OUTPUT=$(eval "$PROJ_CMD")
PROJ_EXIT_CODE=$?
echo "$PROJ_OUTPUT"
if [[ $PROJ_EXIT_CODE != 0 ]]; then
    exit 1
fi

PROJECT="${PROJ_OUTPUT##*/}"
SCHEME="${PROJECT%.xcodeproj}"

TEST_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -sdk $SDK -enableCodeCoverage YES test"
echo "Running $TEST_CMD"
eval "$TEST_CMD"
if [[ $? != 0 ]]; then
    exit 1
fi

BASH_CMD="bash <(curl -s https://codecov.io/bash)"
for pkg in $(ls -F Sources/ 2>/dev/null | grep '/$'); do   # get only directories in "Sources/"
    pkg=${pkg%/}                                           # remove trailing slash
    BASH_CMD+=" -J '^${pkg}\$'"
done

echo "Running $BASH_CMD"
eval "$BASH_CMD"
if [[ $? != 0 ]]; then
    echo "Error running codecov.io bash script"
    exit 1
fi

echo "Successfully generated codecov.io report"
