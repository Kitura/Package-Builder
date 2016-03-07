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

# If any commands fail, we want the shell script to exit immediately.
set -e

echo "projectFolder: ${projectFolder}"

# Set authentication password for redis server
password=$(head -n 1 "${projectFolder}/Tests/SwiftRedisAuth/password.txt")
echo "redis password: $password"

# Start redis server
redis-server &

ls -la /etc

echo "contents of redis.conf before"
cat /etc/redis/redis.conf

redis-cli shutdown
# Update redis password
perl -pi -e 's/# requirepass foobared/# requirepass $password/g' /etc/redis/redis.conf

echo "contents of redis.conf after"
cat /etc/redis/redis.conf

# Start redis server
redis-server &
