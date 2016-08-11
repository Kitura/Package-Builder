/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// module.exports defined at the bottom of the file

const async = require('async');

// @param repository - Repository
function pushNewVersion(branchName, repository, callback) {
    'use strict';

    console.log(`pushing repository ${repository.getName()}`);

    const push = repository.push.bind(repository);
    const pushTags = repository.pushTags.bind(repository);

    async.series([async.apply(push, branchName),
                  pushTags],
                 error => callback(error, repository));
}

// @param repositories - Repository
function pushNewVersions(branchName, repositories, callback) {
    'use strict';
    async.map(repositories, async.apply(pushNewVersion, branchName), callback);
}

module.exports = pushNewVersions;
