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

# This script builds the Kitura sample app on OS X (Travis CI).
# Homebrew (http://brew.sh/) must be installed on the OS X system for this
# script to work.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Determine platform/OS
echo "os: $(uname)"
if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    echo "os x"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    echo "linux"
else
    echo "Unsupported platform!"
    exit 1
fi

# Make the working directory the folder from which the script was sourced
cd "$(dirname "$0")"

# Get project name from project folder
currentDir=`pwd`
projectName="$(basename $currentDir)"
echo "projectName: $projectName"

# Build swift package
swift build -Xcc -fblocks
#swift build -Xcc -fblocks -Xcc -fmodule-map-file=Packages/Kitura-HttpParserHelper-0.3.1/module.modulemap -Xcc -fmodule-map-file=Packages/Kitura-CurlHelpers-0.3.0/module.modulemap -Xcc -fmodule-map-file=Packages/Kitura-Pcre2-0.2.0/module.modulemap

# Copy test credentials for project if available
if [ -e "Kitura-TestingCredentials/${projectName}" ]; then
	echo "Found folder with test credentials for ${projectName}."
  # Copy tests using gradle script
  ./DevOps/gradle_wrapper/gradlew copyProperties -b copy-project-properties.gradle -PappOpenSourceFolder=${currentDir}/Kitura-TestingCredentials/${projectName} -PappRootFolder=$currentDir
else
  echo "No folder found with test credentials for ${projectName}."
fi

# Execute test cases
# swift test
