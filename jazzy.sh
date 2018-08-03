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

# Check that we have credentials. In addition to the username and password,
# we require an e-mail address for configuring our user when pushing docs
# updates back to Github.
if [ -z "${GITHUB_USERNAME}" -o -z "${GITHUB_PASSWORD}" -o -z "${GITHUB_EMAIL}" ]; then
    echo "Supplied jazzy docs flag, but credentials were not provided."
    echo "Expected: GITHUB_USERNAME, GITHUB_PASSWORD and GITHUB_EMAIL Env variables."
    exit 1
fi

# Check that projectFolder and SCRIPT_DIR exist. These should have been set
# by the calling script (build-package.sh)
if [ -z "${projectFolder}" ]; then
    projectFolder="$pwd"
    echo "Warning: projectFolder not set. Defaulting to pwd ($projectFolder)"
fi

if [ -z "${SCRIPT_DIR}" ]; then
    # Determine location of this script
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    echo "Warning: SCRIPT_DIR not set. Defaulting to current script location ($SCRIPT_DIR}"
fi

# Check if .jazzy.yaml exists in the root folder of the repo. If we do not find
# it, fail the build because the build explicitly requested docs generation.
if [ ! -f "${projectFolder}/.jazzy.yaml" ]; then
    echo ".jazzy.yaml file does not exist"
    exit 1
fi

# Checkout to the current branch. The repo cloned by Travis is a shallow clone,
# so we cannot check out the branch directly. Instead, create a new remote for
# this purpose and checkout the branch from there.
git remote add jazzy https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${TRAVIS_REPO_SLUG}.git
git fetch jazzy
git checkout jazzy/${TRAVIS_PULL_REQUEST_BRANCH} -b ${TRAVIS_PULL_REQUEST_BRANCH}

# Check whether the latest commit is itself a jazzy-doc commit, and bail out if
# so. Otherwise, we would loop indefinitely creating documentation commits.
LATEST_COMMIT_MESSAGE=`git log -1 --oneline`
GIT_SUCCESS=$?
if [ $GIT_SUCCESS -ne 0 -o -z "${LATEST_COMMIT_MESSAGE}" ]; then
    echo "Failed to get latest commit message - aborting."
    exit 1
fi
if [[ "${LATEST_COMMIT_MESSAGE}" =~ "[jazzy-doc]" ]]; then
    echo "Skipping jazzy-doc generation: latest commit is a jazzy-doc commit."
    exit 0
fi

# Install jazzy (version set to 0.9.1 until https://github.com/realm/jazzy/issues/972 is fixed)
sudo gem install jazzy -v 0.9.1
# Generate xcode project
sourceScript "${SCRIPT_DIR}/generate-xcodeproj.sh" "xcodeproj generation"
# Run jazzy
jazzy

# Configure user
git config --global --add user.name Auto-Jazzy
git config --global --add user.email ${GITHUB_EMAIL}
git config --global --add push.default simple

# Push the updated docs as a new commit to the PR branch
git add docs/.
git commit -m '[jazzy-doc] Documentation update'
git push
