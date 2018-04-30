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

# Check that the project is eligible for a podspec, based on the POD_ELIGIBLE tag in the travis file
if [ "$(uname)" == "Darwin" ] && [ "${TRAVIS_PULL_REQUEST}" != "false" ] && [ $POD_ELIGIBLE ]; then
    if  [ -n "${GITHUB_USERNAME}" -a -n "${GITHUB_PASSWORD}" ]; then

        # Determine project name
        cd "$(dirname "$0")"/..
        export projectFolder=`pwd`
        projectName="$(basename $projectFolder)"
        echo ">> projectName: $projectName"

        # Create the podspec file
        podFile="$projectName.podspec"
        touch "$podFile}
        podDirectory=${projectFolder}/${podFile}

        # Create and populate the contents of the podspec file
        # Need to also consider the possibility of source files also being in folders that don't match the project name
        podspec="Pod::Spec.new do |s|\ns.name        = \"$projectName\"\ns.version     = \"5.0.1\"\ns.summary     = \"$TRAVIS_DESCRIPTION\"\ns.homepage    = \"https://github.com/IBM-Swift/$projectName\"\ns.license     = { :type => \"Apache License, Version 2.0\" }\ns.author     = \"IBM\"\ns.module_name  = '$projectName'\ns.requires_arc = true\ns.ios.deployment_target = \"10.0\"\ns.source   = { :git => \"https://github.com/IBM-Swift/$projectName.git\", :tag => s.version }\ns.source_files = \"Sources/$projectName/*.swift\"\ns.pod_target_xcconfig =  {\n'SWIFT_VERSION' => '4.0.3',\n}"

        # Check that a Package.swift file exists, extract dependencies, and use within the podspec file
        if [ -e "$Package.swift" ]; then
            echo "Package.swift file found, may contain dependencies."
            # Get and append dependencies - TO DO
            dependency = ""
            podspec = podspec + "\ns.dependency '$dependency'\nend"
        else
            podspec = podspec + "\nend"
        fi

        # Copy the variable contents to the podspec file
        echo "$podspec" >> "$podDirectory"

        # Do a pod lint to check for warnings and errors
        pod lib lint

        # Need to check result of pod lint and terminate if there are warnings or errors - TO DO

        # Configure endpoint, and upload the podspec to Github
        REPO=`git config remote.origin.url`
        AUTH_REPO=${REPO/https:\/\/github.com\//https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/}
        git add "$projectName".podspec
        git commit -m 'Created podspec file [ci skip]'
        git push

        # Upload the podspec to the Cocoapods Spec
        pod trunk push "$projectName".podspec

        # Need to check successful upload to the Cocoapods Spec - TO DO

        exit 1
    else
        echo "Expected: GITHUB_USER && GITHUB_PASSWORD Env variables."
    fi
else
    echo "Expected this to be a pull request. Skipping podspec generation."
fi

