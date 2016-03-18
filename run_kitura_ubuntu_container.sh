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

# This script builds the corresponding Kitura Swift Package in a
# Docker ubuntu container (Travis CI).

# If any commands fail, we want the shell script to exit immediately.
set -e

# Parse input parameters
# Determnine branch to build
if [ -z "$1" ]
  then
    branch="develop"
  else
    branch=$1
fi
echo ">> branch: $branch"

# Determine volume to mount from host to docker container
# Determine command clause (project path)
if [[ (-z "$2") && (-z "$3") ]]
  then
    volumeClause=""
    cmdClause=""
  else
    hostFolder=$2
    projectName=$3
    volumeClause="-v $hostFolder:/root/$projectName"
    cmdClause="/root/$projectName/Kitura-Build/build_kitura_package.sh"
fi
echo ">> volumeClause: $volumeClause"
echo ">> cmdClause: $cmdClause"

# Pull down docker image
docker pull ibmcom/kitura-ubuntu:latest

# Run docker container
# Please note that when a volume from the host is mounted on the container,
# if the same folder already exists in the container, then it is replaced
# with the contents from the host.
docker run --rm -e KITURA_BRANCH=$branch $volumeClause ibmcom/kitura-ubuntu:latest $cmdClause
