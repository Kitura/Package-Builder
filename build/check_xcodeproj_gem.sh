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

RUBYCOUNT=`which ruby | wc -l`
if [ "$RUBYCOUNT" -lt 1 ]
then
   echo "ruby is not installed. Please install it: brew install ruby"
fi

GEMCOUNT=`which gem | wc -l`
if [ "$GEMCOUNT" -lt 1 ]
then
   # gem is installed by installing ruby
   echo "gem is not installed. Please install it: brew install ruby"
fi

XCODEPROJCOUNT=`gem list 2>/dev/null | grep xcodeproj | wc -l`
if [ "$XCODEPROJCOUNT" -lt 1 ]
then
   echo "xcodeproj gem is not installed. Please install it by running: gem install xcodeproj"
fi
