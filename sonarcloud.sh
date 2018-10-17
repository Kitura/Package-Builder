#! /bin/bash

##
# Copyright Ladislas de Toldi 2018
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

if [[ $TRAVIS_BRANCH != "master" && $TRAVIS_BRANCH != "develop" && $TRAVIS_EVENT_TYPE != "cron" ]]; then
  echo "Not master, develop or cron build. Skipping code coverage generation."
  exit 0
fi

echo ">> Starting Sonar Cloud code coverage analysis..."
uname -a

SDK=macosx
DERIVED_DATA=.build/scanner
xcodebuild -version
xcodebuild -version -sdk $SDK
if [[ $? != 0 ]]; then
  exit 1
fi

# Determine if there is a custom command for generating xcode project
source ./Package-Builder/generate-xcodeproj.sh

# Determine if there is a custom command for xcode build (code coverage tests)
if [ -e ${projectFolder}/.swift-codecov ]; then
  XCODE_BUILD_CMD=$(cat ${projectFolder}/.swift-codecov)
else
  PROJECT="${PROJ_OUTPUT##*/}"
  SCHEME=$(xcodebuild -list -project $PROJECT | grep --after-context=1 '^\s*Schemes:' | tail -n 1 | xargs)
  XCODE_BUILD_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -derivedDataPath $DERIVED_DATA -enableCodeCoverage YES clean build test CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO"
fi

echo ">> Running: $XCODE_BUILD_CMD"
eval "$XCODE_BUILD_CMD"
if [[ $? != 0 ]]; then
  echo ">> Error running: $XCODE_BUILD_CMD"
  exit 1
fi

BASH_BASE="bash <(cat ${SCRIPT_DIR}/xccov-to-sonarcloud-report.sh)"
XCCOV_ARCHIVE_PATH="$DERIVED_DATA/Logs/Test/*.xcresult/*_Test/action.xccovarchive/"
if [ -z ${SONAR_COVERAGE_REPORT_PATH+x} ]; then
SONAR_COVERAGE_REPORT_PATH="sonarscanner-coverage-report.xml"
fi

BASH_CMD="$BASH_BASE $XCCOV_ARCHIVE_PATH > $SONAR_COVERAGE_REPORT_PATH"

echo ">> Running: $BASH_CMD"
eval "$BASH_CMD"
if [[ $? != 0 ]]; then
  echo ">> Error running: $BASH_CMD"
  exit 1
fi

if [ -e ${projectFolder}/.swift-sonarcloud ]; then
  echo ".swift-sonarcloud found, running sonar-scanner with .swift-sonarcloud."
  SONAR_UPLOAD_CMD=$(cat ${projectFolder}/.swift-sonarcloud)
elif [ -e ${projectFolder}/sonar-project.properties ]; then  
  echo "sonar-project.properties found, running sonar-scanner with sonar-project.properties."
  SONAR_UPLOAD_CMD="sonar-scanner -Dsonar.login=$SONAR_LOGIN_TOKEN"
else
  echo ".swift-sonarcloud not found, running sonar-scanner env variables provided by .travis.yml"
  SONAR_UPLOAD_CMD="sonar-scanner \
      -Dsonar.projectKey=$SONAR_PROJECT_KEY \
      -Dsonar.organization=$SONAR_ORGANIZATION \
      -Dsonar.sources=\"${SONAR_SOURCES}\" \
      -Dsonar.exclusions=\"Package-Builder/**, ${SONAR_COVERAGE_REPORT_PATH}, ${SONAR_SOURCES_EXCLUSIONS}\" \
      -Dsonar.tests=\"${SONAR_TESTS}\" \
      -Dsonar.coverageReportPaths=\"${SONAR_COVERAGE_REPORT_PATH}\" \
      -Dsonar.coverage.exclusions=\"${SONAR_COVERAGE_EXCLUSIONS}\" \
      -Dsonar.host.url=https://sonarcloud.io \
      -Dsonar.login=$SONAR_LOGIN_TOKEN"
fi

echo ">> Running: $SONAR_UPLOAD_CMD"
eval "$SONAR_UPLOAD_CMD"
if [[ $? != 0 ]]; then
  echo ">> Error running: $SONAR_UPLOAD_CMD"
  exit 1
fi

echo ">> Finished code coverage analysis."
