#!/bin/bash

#/**
#* Copyright IBM Corporation 2016
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#**/

APP_NAME=$(basename `pwd`)
MAIN_MODULE_NAME=$(basename `find Sources -name "main.swift" -exec dirname {} \;`)
echo --- Pushing ${APP_NAME}, command to run: ${MAIN_MODULE_NAME}
echo cf push ${APP_NAME} --no-manifest -b swift_buildpack -m 256M -i 1 --random-route -k 1024M -c ${MAIN_MODULE_NAME}
