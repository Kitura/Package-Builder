#!/bin/bash

##
# Copyright IBM Corporation 2016,2017
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

DEFAULT_SWIFT=swift-4.0.2-RELEASE

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

# Determine platform/OS and project name
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

cd "$(dirname "$0")"/..
export projectFolder=`pwd`
projectName="$(basename $projectFolder)"
echo ">> projectName: $projectName"

# Install swift binaries based on OS
source ./Package-Builder/install-swift.sh

# Show path
echo ">> PATH: $PATH"
echo

# Build swift package
echo ">> Building Swift package..."

cd ${projectFolder}

if [ -e ${projectFolder}/.swift-build-macOS ] && [ "${osName}" == "osx" ]; then
  echo Running custom macOS build command: `cat ${projectFolder}/.swift-build-macOS`
  source ${projectFolder}/.swift-build-macOS
elif [ -e ${projectFolder}/.swift-build-linux ] && [ "${osName}" == "linux" ]; then
  echo Running custom Linux build command: `cat ${projectFolder}/.swift-build-linux`
  source ${projectFolder}/.swift-build-linux
else
  swift build
fi

echo ">> Finished building Swift package."

# Copy test credentials for project if available
if [ -e "${credentialsDir}" ]; then
  echo ">> Found folder with test credentials."

  # Copy test credentials over
  echo ">> copying ${credentialsDir} to ${projectBuildDir}"
  cp -RP ${credentialsDir}/* ${projectBuildDir}
else
  echo ">> No folder found with test credentials."
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
    echo ">> No test cases found."
fi

# Run SwiftLint to ensure Swift style and conventions (macOS)
if [ "$(uname)" == "Darwin" ]; then
  # Is the repository overriding the default swiftlint file in pacakge builder?
  if [ -e "${projectFolder}/.swiftlint.yml" ]; then
    # Determine whether custom swiftlint contains "excluded:" section
    if ! grep -q "excluded:" ${projectFolder}/.swiftlint.yml; then    # Add "excluded:"" section to .swiftlint.yml
      echo "excluded:" >> ${projectFolder}/.swiftlint.yml
    fi
    # Add "  - Package-Builder" to section
    sed -i '' 's/excluded:/excluded:\
  - Package-Builder/g' ${projectFolder}/.swiftlint.yml

    # Print linter version
    echo "Running linter swiftlint version $(swiftlint version)"

    swiftlint lint --quiet --config ${projectFolder}/.swiftlint.yml
  #else
  #swiftlint lint --quiet --config ${projectFolder}/Package-Builder/.swiftlint.yml
  fi
fi

# Generate test code coverage report (macOS)
if [ "$(uname)" == "Darwin" ]; then
  if [ -e ${projectFolder}/.swift-codecov ]; then
      source ${projectFolder}/.swift-codecov
  else
      sourceScript "${projectFolder}/Package-Builder/codecov.sh"
  fi
fi

# Clean up build artifacts
# If at some point we integrate this script in a toolchain/pipeline,
# we will need to resurrect the code below
#rm -rf ${projectFolder}/.build
#rm -rf ${projectFolder}/Packages
#rm -rf ${projectFolder}/${SWIFT_SNAPSHOT}-${UBUNTU_VERSION}
# Clean up build artifacts