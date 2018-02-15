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

# This script builds the Swift package on Travis CI.
# If running on the OS X platform, homebrew (http://brew.sh/) must be installed
# for this script to work.

# If any commands fail, we want the shell script to exit immediately.

function checkError() {
    if [ ! -d "$jazzy" ]; then
        ERROR=1
    fi
}

mv library ../../library
mv executable ../../executable
cp -R ../ ../../library/Package-Builder
cp -R ../ ../../executable/Package-Builder
cp -R ../../executable ../executable-no-swift-version
rm ../../executable-no-swift-version/.swift-version

ERROR=0
# This tests Package-Builder with a library
cd ../../library
./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR/library
checkError()
# This tests Package-Builder with an executable
cd ../executable
./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR/executable
checkError()
# Test building a package that does not have a .swift-version file
cd ../executable-no-swift-version
./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR/executable-no-swift-version
checkError()

if [ $ERROR == 1 ]; then
    echo "Jazzy files were not created"
    exit(1)
fi
