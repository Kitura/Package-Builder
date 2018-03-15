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

# Check that projectFolder and SCRIPT_DIR exist
if [ -z "${projectFolder}" ]; then
    projectFolder="$pwd"
    echo "Warning: projectFolder not set. Defaulting to pwd ($projectFolder)"
fi

if [ -z "${SCRIPT_DIR}" ]; then
    # Determine location of this script
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    echo "Warning: SCRIPT_DIR not set. Defaulting to current script location ($SCRIPT_DIR}"
fi

# Check if .jazzy.yaml exists in the root folder of the repo
if [ ! -f "${projectFolder}/.jazzy.yaml" ]; then
    echo ".jazzy.yaml file does not exist"
    exit 1
fi

# Checkout to the current branch. The repo cloned by Travis is a shallow clone,
# so we cannot just check out the branch. Instead, create a new remote for this
# purpose and checkout the branch from there.
git remote add jazzy https://github.com/${TRAVIS_REPO_SLUG}.git
git fetch jazzy
git checkout jazzy/${TRAVIS_PULL_REQUEST_BRANCH} -b ${TRAVIS_PULL_REQUEST_BRANCH}

# Install jazzy
sudo gem install jazzy
# Generate xcode project
sourceScript "${SCRIPT_DIR}/generate-xcodeproj.sh" "xcodeproj generation"
# Run jazzy
jazzy

# Configure endpoint
REPO=`git config remote.origin.url`
AUTH_REPO=${REPO/https:\/\/github.com\//https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/}

git add docs/.
git commit -m 'Documentation update [ci skip]'
git push
