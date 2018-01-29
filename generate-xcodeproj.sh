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

# Determine if there is a custom command for generating xcode project
CUSTOM_XCODE_PROJ_GEN_CMD="${projectFolder}/.swift-xcodeproj"
if [[ -f "$CUSTOM_XCODE_PROJ_GEN_CMD" ]]; then
  echo ">> Running custom xcodeproj command: $(cat $CUSTOM_XCODE_PROJ_GEN_CMD)"
  PROJ_OUTPUT=$(source "$CUSTOM_XCODE_PROJ_GEN_CMD")
else
  PROJ_OUTPUT=$(swift package generate-xcodeproj)
fi

PROJ_EXIT_CODE=$?
echo "$PROJ_OUTPUT"
if [[ $PROJ_EXIT_CODE != 0 ]]; then
  exit 1
fi
