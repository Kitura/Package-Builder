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
const spmHandler = require( __dirname + '/spmHandler.js');
const SwiftVersionHandler = require( __dirname + '/swiftVersionHandler.js');

function composeDetailsUpdatePackageDotSwiftCommitMessage(updatedDependencies) {
    'use strict';
    return updatedDependencies.reduce((message, dependency) => {
        return message + `set version of ${dependency.dependencyURL} to ${dependency.version}\n`;
    },"");
}

// @param repository - simplegit repository
function commitPackageDotSwift(repository, updatedDependencies, callback) {
    'use strict';

    var message = 'updated dependency versions in Package.swift';
    var detailsMessage = composeDetailsUpdatePackageDotSwiftCommitMessage(updatedDependencies);
    repository.commit(message, 'Package.swift', { '--message': detailsMessage}, callback);
}

// @param repository - Repository
function updatePackageDotSwift(repository, versions, callback) {
    'use strict';
    spmHandler.updateDependencies(repository.getDirectory(), repository.packageJSON,
        versions, (error, updatedDependencies) => {
            if (error) {
                return callback(error);
            }
            if (!updatedDependencies) {
                return callback('no updatedDependencies returned from updateDependencies');
            }
            updatedDependencies = updatedDependencies.filter(member => member);
            if (updatedDependencies.length > 0) {
                return commitPackageDotSwift(repository.simplegitRepository,
                                             updatedDependencies, callback);
            }
            callback(null);
        });
}

// @param repository - Repository
function updateRepository(branchName, swiftVersion, versions, repository, callback) {
    'use strict';

    const swiftVersionHandler = new SwiftVersionHandler(repository, swiftVersion);
    const updateSwiftVersion = swiftVersionHandler.updateSwiftVersion.bind(swiftVersionHandler);

    const createBranch = repository.createBranch.bind(repository);
    const addTag = repository.addTag.bind(repository);

    async.series([async.apply(createBranch, branchName),
                  async.apply(updatePackageDotSwift, repository, versions),
                  updateSwiftVersion,
                  async.apply(addTag, versions[repository.getCloneURL()])],
                 error => callback(error, repository));
}

// @param repositories - Repository
function updateLocally(branchName, swiftVersion, allRepositories, changedRepositories,
                       versions, callback) {
    'use strict';
    const update = async.apply(updateRepository, branchName, swiftVersion, versions);
    async.map(changedRepositories, update, () => callback(null, allRepositories));
}

module.exports = updateLocally;
