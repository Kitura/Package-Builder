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

# This script builds the Kitura sample app on Travis CI.
# If running on the OS X platform, homebrew (http://brew.sh/) must be installed
# for this script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Swift version for build
export SWIFT_SNAPSHOT=swift-DEVELOPMENT-SNAPSHOT-2016-06-06-a
echo ">> SWIFT_SNAPSHOT: $SWIFT_SNAPSHOT"
export WORK_DIR=/root

# Utility functions
function sourceScript () {
  if [ -e "$1" ]; then
  	source "$1"
    echo "$2"
  fi
}

# Determine platform/OS
echo ">> uname: $(uname)"
if [ "$(uname)" == "Darwin" ]; then
  osName="osx"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  osName="linux"
else
  echo ">> Unsupported platform!"
  exit 1
fi
echo ">> osName: $osName"

# Make the working directory the parent folder of this script
cd "$(dirname "$0")"/..

# Get project name from project folder
export projectFolder=`pwd`
projectName="$(basename $projectFolder)"
echo ">> projectName: $projectName"
echo

# Install Swift binaries
source ${projectFolder}/Kitura-Build/${osName}/install_swift_binaries.sh

# Show path
echo ">> PATH: $PATH"

# Run SwiftLint to ensure Swift style and conventions
# swiftlint

# Build swift package from makefile
echo ">> Running makefile..."
cd ${projectFolder} && make
echo ">> Finished running makefile"


# Copy test credentials for project if available
if [ -e "${projectFolder}/Kitura-TestingCredentials/${projectName}" ]; then
	echo ">> Found folder with test credentials for ${projectName}."
  # Copy tests using gradle script (note that we are using the convenient gradle wrapper...)
  ./DevOps/gradle_wrapper/gradlew copyProperties -b ./DevOps/scripts_assets/gradle_assets/build-deploy-assets/copy-project-properties.gradle -PappOpenSourceFolder=${projectFolder}/Kitura-TestingCredentials/${projectName} -PappRootFolder=${projectFolder}
else
  echo ">> No folder found with test credentials for ${projectName}."
fi

# Execute OS specific pre-test steps
sourceScript "${projectFolder}/Kitura-Build/${projectName}/${osName}/before_tests.sh" ">> Completed ${osName} pre-tests steps."

# Execute common pre-test steps
sourceScript "${projectFolder}/Kitura-Build/${projectName}/common/before_tests.sh" ">> Completed common pre-tests steps."

# Execute test cases
if [ -e "${projectFolder}/Tests" ]; then
    echo ">> Testing Kitura package..."
    swift test
    echo ">> Finished testing Kitura package."
    echo
else
    echo ">> No testcases exist..."
fi


# Execute common post-test steps
sourceScript "${projectFolder}/Kitura-Build/${projectName}/common/after_tests.sh" ">> Completed common post-tests steps."

# Execute OS specific post-test steps
sourceScript "${projectFolder}/Kitura-Build/${projectName}/${osName}/after_tests.sh" ">> Completed ${osName} post-tests steps."
