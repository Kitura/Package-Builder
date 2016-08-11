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

const semver = require('semver');
const async = require('async');
const Repository = require( __dirname + '/repository.js');

// @param repository - Repository
function isKituraCoreRepository(repository) {
    'use strict';
    return repository.getName().startsWith('Kitura');
}

// @param repository - Repository
function getBumpedVersion(repository, kituraVersion) {
    'use strict';
    if (isKituraCoreRepository(repository)) {
        return kituraVersion;
    }
    return semver.inc(repository.largestVersion, 'minor');
}

function subtractArray(array1, array2) {
    'use strict';
    return array1.filter(member => array2.indexOf(member) < 0);
}

function appendWithoutDuplicates(array1, array2) {
    'use strict';
    array2.forEach(member => {
        if (array1.indexOf(member) < 0) {
            array1.push(member);
        }
    });

}

// @param dependeeRepositories - Repository
function doesRepositoryDependOn(packageJSON, dependeeRepositories) {
    'use strict';
    return packageJSON.dependencies.some(dependency =>
        dependeeRepositories.some(dependeeRepository =>
                                  dependeeRepository.getCloneURL() === dependency.url));
}

// @param repositoriesToCheck - Repository
// @param dependeeRepositories - Repository
function getDependentRepositories(repositoriesToCheck, dependeeRepositories) {
    'use strict';
    return repositoriesToCheck.filter(repository =>
        doesRepositoryDependOn(repository.packageJSON, dependeeRepositories));
}

// @param repositoriesToCheck - Repository
function getChangedRepositories(repositories, callback) {
    'use strict';
    async.filter(repositories, (repository, callback) =>
                 repository.wasChangedAfterVersion(repository.largestVersion, callback),
                 callback);
}

function isNonReleaseTag(tag) {
    'use strict';
    return semver.minor(tag) % 2; // the convention in Kitura is that release tags are even
}

// @param repositoriesToCheck - Repository
function getNonReleasedCoreRepositories(repositories, callback) {
    'use strict';
    async.filter(repositories, (repository, callback) => callback(null,
        isNonReleaseTag(repository.largestVersion) && isKituraCoreRepository(repository)),
            callback);
}

// another option is to use 'swift package show-dependencies --format json', however
// it will clone all the dependency packages transitively, for all the repositories
// in our case, all the repositories are already cloned
// dependee terms from https://en.wiktionary.org/wiki/dependee
function getTransitiveClosureOfDependencies(repositoriesToCheck, dependeeRepositories) {
    'use strict';
    // we define that dependee repositories depened on themselves in a trivial way
    var dependentRepositories = dependeeRepositories;
    var currentDependeeRepositories = dependeeRepositories;
    var currentRepositoriesToCheck = repositoriesToCheck;
    var currentDependentRepositories = [];
    var iteration = 0;
    var maximalNumberOfIterations = repositoriesToCheck.length;

    while (currentDependeeRepositories.length > 0 && iteration < maximalNumberOfIterations) {
        console.log(`calculating transitive closure of dependencies iteration ${iteration++}`);

        currentDependentRepositories =
            getDependentRepositories(currentRepositoriesToCheck, currentDependeeRepositories);
        Repository.log(currentDependentRepositories,
                       'repositories that depend on changed repositories', null, true);

        dependentRepositories = dependentRepositories.concat(currentDependentRepositories);
        currentDependeeRepositories = currentDependentRepositories;
        currentRepositoriesToCheck = subtractArray(currentRepositoriesToCheck,
                                                   currentDependentRepositories);
    }

    return dependentRepositories;
}

// @param repositories - Repository
function getRepositoriesToBumpVersion(repositories, callback) {
    'use strict';
    async.parallel({ changedRepositories: async.apply(getChangedRepositories,repositories),
        nonReleasedCoreRepositories: async.apply(getNonReleasedCoreRepositories,repositories)},
            (error, result) => {
                var changedRepositories = result.changedRepositories;
                const nonReleasedCoreRepositories = result.nonReleasedCoreRepositories;

                Repository.log(changedRepositories, `${changedRepositories.length}` +
                               ` repositories changed after last tag`);
                Repository.log(nonReleasedCoreRepositories,
                               `${nonReleasedCoreRepositories.length} core repositories` +
                               ` have non release tag`);

                appendWithoutDuplicates(changedRepositories, nonReleasedCoreRepositories);
                const unchangedRepositories = subtractArray(repositories, changedRepositories);
                Repository.log(unchangedRepositories,
                               `${unchangedRepositories.length} repositories unchanged`);

                callback(null, getTransitiveClosureOfDependencies(unchangedRepositories,
                                                                  changedRepositories));
            });
}

// @param repositories - Repository
function getNewVersions(kituraVersion, repositories, callback) {
    'use strict';

    Repository.log(repositories, `get new versions of ${repositories.length} repositories`);
    getRepositoriesToBumpVersion(repositories, (error, repositoriesToBumpVersion) => {
        var newVersions = {};
        repositoriesToBumpVersion.forEach(repository =>
            newVersions[repository.getCloneURL()] = getBumpedVersion(repository, kituraVersion));

        callback(null, repositories, repositoriesToBumpVersion, newVersions);
    });
}

module.exports = {getNewVersions: getNewVersions};
