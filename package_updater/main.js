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

const ORGANIZATION_NAME = 'IBM-Swift';
const WHITELIST_FILE = 'whitelist.txt';
const KITURA_WIKI_REPOSITORIES_PAGE =
      'https://github.com/IBM-Swift/Kitura/wiki/Kitura-repositories';

const async = require('async-if-else')(require('async'));
const colors = require('colors/safe');

const makeWorkDirectory = require( __dirname + '/makeWorkDirectory.js');
const getRepositoriesFromWiki = require( __dirname + '/getRepositoriesFromWiki.js');
const getRepositoriesFromFile = require( __dirname + '/getRepositoriesFromFile.js');

const Repository = require( __dirname + '/repository.js');
const Parameters = require( __dirname + '/parameters.js');
const versionHandler = require( __dirname + '/versionHandler.js');
const spmHandler = require( __dirname + '/spmHandler.js');
const Github = require( __dirname + '/github.js');

const clone = require( __dirname + '/clone.js');
const updateLocally = require( __dirname + '/updateLocally.js');
const push = require( __dirname + '/push.js');
const submitPRs = require( __dirname + '/submitPRs.js');

const parameters = new Parameters();
var github = new Github(ORGANIZATION_NAME);
var branchName = "";

function setup(callback) {
    'use strict';

    function shouldReadFromWiki(github, callback) {
        console.log(colors.green('The list repositories to handle can be obtained from Kitura' +
                                 'repositories wiki page: ' + KITURA_WIKI_REPOSITORIES_PAGE));
        console.log(colors.green('Alternatively, it can be read from a whitelist file of ' +
                                 'repository names: ' + WHITELIST_FILE));
        parameters.shouldReadFromWiki(callback);
    }

    function getRepositories(callback) {
        async.waterfall([
            github.authenticate.bind(github),
            async.if(shouldReadFromWiki,
                     async.apply(getRepositoriesFromWiki, KITURA_WIKI_REPOSITORIES_PAGE))
                .else(async.apply(getRepositoriesFromFile, WHITELIST_FILE))
                    ], callback);
    }

    async.parallel({ workDirectory: makeWorkDirectory,
                     repositoriesToHandle: getRepositories,
                   }, (error, results) =>  callback(error, results.repositoriesToHandle,
                                                    results.workDirectory));
}

function getGoodByeMessage() {
    'use strict';
    return 'Done';
}

function shouldClone(repositories, workDirectory, callback) {
    'use strict';
    console.log(colors.green(`going to clone ${repositories.length} repositories` +
                             ` into ${workDirectory}`));
    if (repositories.length < 1) {
        return callback(null, false);
    }
    parameters.shouldClone(callback);
}

function shouldUpdateLocally(repositories, changedRepositories, versions, callback) {
    'use strict';

    console.log(colors.green(`${changedRepositories.length} cloned repositories to update` +
                             ' locally.'));
    if (changedRepositories.length < 1) {
        return callback(null, false);
    }
    console.log(colors.green('No changes will be pushed to remote repositories at this step'));

    changedRepositories.forEach(repository =>
        console.log(colors.green(`${repository.getName()} ${versions[repository.getCloneURL()]}`)));
    parameters.shouldUpdateLocally(callback);
}

function shouldPush(repositories, callback) {
    'use strict';
    Repository.getCredentials(credentials => {
        console.log(`credentials to be used: ${credentials.name} ${credentials.email}`);
        Repository.log(repositories, `${repositories.length} repositories to be pushed`,
                       colors.red);
        if (repositories.length < 1) {
            return callback(null, false);
        }
        parameters.shouldPush(callback);
    });
}

function shouldSubmitPRs(repositories, callback) {
    'use strict';
    Repository.log(repositories, `${repositories.length} repositories to submit PRs`,
                   colors.red);
    if (repositories.length < 1) {
        return callback(null, false);
    }
    console.log(colors.red(`github user id ${github.getUserName()} will be used`));
    parameters.shouldSubmitPRs(callback);
}


// @param repositories githubRepository
function filterByPackageDotSwift(repositories, workDirectory, callback) {
    'use strict';
    async.filter(repositories,
                 (repository, callback) =>
                 spmHandler.hasPackageDotSwift(Repository.getDirectory(workDirectory, repository),
                                               callback),
                 (error, repositories) => callback(error, repositories, workDirectory));
}

// @param repositories githubRepository
function createRepositories(repositories, workDirectory, callback) {
    'use strict';
    async.map(repositories, async.apply(Repository.create, workDirectory), callback);
}

function discardChangedRepositoriesAndVersionsParameters(allRepositories, changedRepositories,
                                                         versions, callback) {
    'use strict';
    callback(null, allRepositories);
}

// @param repositories Repository
function filterByBranchName(branchName, repositories, callback) {
    'use strict';
    async.filter(repositories, (repository, callback) => repository.hasBranch(branchName, callback),
                 callback);
}

// @param repositories Repository
function filterByTagExistance(repositories, callback) {
    'use strict';
    async.filter(repositories, (repository, callback) => callback(null, repository.largestVersion),
                 callback);
}

// @param repositories Repository
function filterByNotChangedAfterMaster(repositories, callback) {
    'use strict';

    async.filter(repositories, (repository, callback) => {
        repository.wasChangedAfterVersion('master', (error, wasChanged) => {
            if (!wasChanged) {
                console.log(colors.magenta(`repository ${repository.getName()} was not changed`));
            }
            callback(error, wasChanged);
        }, callback);
    }, callback);
}

parameters.read(() => {
    'use strict';
    console.log(`setting Kitura Version to ${parameters.kituraVersion}`);
    console.log(`setting swift version to ${parameters.swiftVersion}`);
    branchName = `automatic_migration_to_${parameters.kituraVersion}`;

    async.waterfall([setup,
                     async.if(shouldClone, clone),
                     filterByPackageDotSwift,
                     createRepositories,
                     filterByTagExistance,
                     async.apply(versionHandler.getNewVersions, parameters.kituraVersion),
                     async.if(shouldUpdateLocally,
                              async.apply(updateLocally, branchName, parameters.swiftVersion))
                         .else(discardChangedRepositoriesAndVersionsParameters),
                     async.apply(filterByBranchName, branchName),
                     filterByNotChangedAfterMaster,
                     async.if(shouldPush, async.apply(push, branchName)),
                     async.if(shouldSubmitPRs,
                              async.apply(submitPRs, branchName, parameters.kituraVersion,
                                          github))],
                    error => {
                        if (error) {
                            return console.error(error);
                        }
                        console.log(getGoodByeMessage());
                    });
});
