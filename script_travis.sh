#!/bin/bash -x

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

## References for triggering builds using Travis CI API
# https://docs.travis-ci.com/user/triggering-builds
# https://api.travis-ci.org/repos/IBM-Swift/Kitura.json

# If any commands fail, we want the shell script to exit immediately.
set -e

# Verify input params
if [ "$#" -ne 4 ]; then
  echo "Usage: script_travis [TRAVIS_OS_NAME] [TRAVIS_BRANCH] [TRAVIS_BUILD_DIR] [PROJECT]"
  exit 1
fi

# Set variables
os=$1
branch=$2
build_dir=$3
project=$4

echo ">> Let's build and test the '$branch' branch for $project."
if [ $os == "linux" ];
then 
   echo ">> Running run_kitura_ubuntu_container.sh $branch $build_dir $project"
   ./run_kitura_ubuntu_container.sh $branch $build_dir $project 
fi
if [ $os == "osx" ];
then 
   echo ">> Running build_kitura_package.sh" 
   ./build_kitura_package.sh
fi
echo ">> Build and tests completed. See above for status."

