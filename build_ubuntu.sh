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

# This script builds the corresponding Kitura Swift Package in a Docker container (Travis CI).

# If any commands fail, we want the shell script to exit immediately.
set -e

# Parse input parameters
if [ -z "$1" ]
  then
    branch=$1
  else
    branch="master"
fi
echo ">> branch: $branch"

if [[ (-z "$2") && (-z "$3") ]]
  then
    volumeClause=""
    cmdClause=""
  else
    hostFolder=$2
    projectName=$3
    volumeClause="-v $hostFolder:/root/$projectName"
    cmdClause="/root/$projectName/build_docker_cmd.sh"
fi
echo ">> volumeClause: $volumeClause"
echo ">> cmdClause: $cmdClause"

# Pull down docker image
docker pull ibmcom/kitura-ubuntu:latest

# Run docker container
docker run --rm -e KITURA_BRANCH=$branch $volumeClause ibmcom/kitura-ubuntu:latest $cmdClause
