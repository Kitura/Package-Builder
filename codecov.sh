#! /bin/bash

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_EVENT_TYPE != "cron" ]]; then
    echo "Not master or cron build. Skipping code coverage generation"
    exit 0
fi

if [[ ${osName} != "osx" ]]; then
    echo "Not osx build. Skipping code coverage generation"
    exit 0
fi

echo "Starting code coverage generation..."
uname -a

SDK=macosx
xcodebuild -version
xcodebuild -version -sdk $SDK
if [[ $? != 0 ]]; then
    exit 1
fi


CUSTOM_FILE="${projectFolder}/.swift-xcodeproj"

if [[ -f "$CUSTOM_FILE" ]]; then
  echo Running custom "$osName" xcodeproj command: $(cat "$CUSTOM_FILE")
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
SCHEME="${PROJECT%.xcodeproj}"

TEST_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -sdk $SDK -enableCodeCoverage YES -skipUnavailableActions test"
echo "Running $TEST_CMD"
eval "$TEST_CMD"
if [[ $? != 0 ]]; then
    exit 1
fi

BASH_BASE="bash <(curl -s https://codecov.io/bash)"
for pkg in $(ls -F Sources/ 2>/dev/null | grep '/$'); do   # get only directories in "Sources/"
    pkg=${pkg%/}                                           # remove trailing slash
    BASH_CMD="$BASH_BASE -J '^${pkg}\$' -F '${pkg}'"

    echo "Running $BASH_CMD"
    eval "$BASH_CMD"
    if [[ $? != 0 ]]; then
        echo "Error running $BASH_CMD"
        exit 1
    fi
done
