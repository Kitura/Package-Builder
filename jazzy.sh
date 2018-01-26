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

# Check if .jazzy.yaml exists in the root folder of the repo
if [[ -e $(projectFolder)/.jazzy.yaml ]]; then
    # Install jazzy
    sudo gem install jazzy
    # Generate xcode project
    cat ${./generate-xcodeproj.sh)
    # Run jazzy
    jazzy
    # Commit and push to relevant branch
    git add *
    git commit -m 'Documentation update [ci skip]'
    git push
fi
