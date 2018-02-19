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

# Check that we have credentials
if [ -z "${GITHUB_USERNAME}" ] && [ -z "${GITHUB_PASSWORD}" ]; then
    echo "Supplied jazzy docs flag, but credentials were not provided."
    echo "Expected: GITHUB_USER && GITHUB_PASSWORD Env variables."
    exit 1
fi

# Check if .jazzy.yaml exists in the root folder of the repo
if [ -e "${projectFolder}"/.jazzy.yaml ]; then

    if [[ $TRAVIS_BRANCH != "master" ]]; then
        echo "Not master. Skipping jazzy generation."
        exit 0
    fi

    # Install jazzy
    sudo gem install jazzy
    # Generate xcode project
    sourceScript "${projectFolder}/generate-xcodeproj.sh"
    # Commit and push to relevant branch
    git checkout master
    # Run jazzy
    jazzy

    # Configure endpoint
    REPO=`git config remote.origin.url`
    AUTH_REPO=${REPO/https:\/\/github.com\//https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/}
  
    git add docs/.
    git commit -m 'Documentation update [ci skip]'
    git push $AUTH_REPO master
fi
