#!/bin/bash

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

# This script builds the Swift package on Travis CI.
# If running on the OS X platform, homebrew (http://brew.sh/) must be installed
# for this script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

function usage {
  echo "Usage: build-package.sh -projectDir <project dir> [-credentialsDir <credentials dir>]"
  echo -e "\t<project dir>: \t\tThe directory where the project resides."
  echo -e "\t<credentials dir>:\tThe directory where the test credentials reside. (optional)"
  exit 1
}

while [ $# -ne 0 ]
do
  case "$1" in
    -projectDir)
      shift
      projectBuildDir=$1
      ;;
    -credentialsDir)
      shift
      credentialsDir=$1
      ;;
  esac
  shift
done

if [ -z "$projectBuildDir" ]; then
  usage
fi

# Utility functions
function sourceScript () {
  if [ -e "$1" ]; then
    source "$1"
    echo "$2"
  fi
}

# Install swift binaries based on OS
cd "$(dirname "$0")"/..
export projectFolder=`pwd`
source ./Package-Builder/install-swift.sh

# Show path
echo ">> PATH: $PATH"

# Run SwiftLint to ensure Swift style and conventions
# swiftlint

# Build swift package
echo ">> Building swift package..."

cd ${projectFolder}

if [ -e ${TRAVIS_BUILD_DIR}/.swift-build-macOS ] && [ "${osName}" == "osx" ]; then
  echo Running custom macOS build command:`cat ${TRAVIS_BUILD_DIR}/.swift-build-macOS`
  source ${TRAVIS_BUILD_DIR}/.swift-build-macOS
elif [ -e ${TRAVIS_BUILD_DIR}/.swift-build-linux ] && [ "${osName}" == "linux" ]; then
  echo Running custom Linux build command: `cat ${TRAVIS_BUILD_DIR}/.swift-build-linux`
  source ${TRAVIS_BUILD_DIR}/.swift-build-linux
else
  swift build
fi

echo ">> Finished building swift package..."

# Copy test credentials for project if available
if [ -e "${credentialsDir}" ]; then
  echo ">> Found folder with test credentials."

  # Copy test credentials over
  echo ">> copying ${credentialsDir} to ${projectBuildDir}"
  cp -RP ${credentialsDir}/* ${projectBuildDir}
else
  echo ">> No folder found with test credentials."
fi

# Run SwiftLint to ensure Swift style and conventions
if [ "$(uname)" == "Darwin" ]; then
  # Is the repository overriding the default swiftlint file in pacakge builder?
  if [ -e "${projectFolder}/.swiftlint.yml" ]; then
    swiftlint lint --config ${projectFolder}/.swiftlint.yml
#  else
#    swiftlint lint --config ${projectFolder}/Package-Builder/.swiftlint.yml
  fi
fi

# Execute test cases
if [ -e "${projectFolder}/Tests" ]; then
    echo ">> Testing Swift package..."
    # Execute OS specific pre-test steps
    sourceScript "`find ${projectFolder} -path "*/${projectName}/${osName}/before_tests.sh" -not -path "*/Package-Builder/*" -not -path "*/Packages/*"`" ">> Completed ${osName} pre-tests steps."

    # Execute common pre-test steps
    sourceScript "`find ${projectFolder} -path "*/${projectName}/common/before_tests.sh" -not -path "*/Package-Builder/*" -not -path "*/Packages/*"`" ">> Completed common pre-tests steps."

    source ./Package-Builder/run_tests.sh

    # Execute common post-test steps
    sourceScript "`find ${projectFolder} -path "*/${projectName}/common/after_tests.sh" -not -path "*/Package-Builder/*" -not -path "*/Packages/*"`" ">> Completed common post-tests steps."

    # Execute OS specific post-test steps
    sourceScript "`find ${projectFolder} -path "*/${projectName}/${osName}/after_tests.sh" -not -path "*/Package-Builder/*" -not -path "*/Packages/*"`" ">> Completed ${osName} post-tests steps."

    echo ">> Finished testing Swift package."
    echo
else
    echo ">> No testcases exist..."
fi

# Generate test code coverage report
sourceScript "${projectFolder}/Package-Builder/codecov.sh"
