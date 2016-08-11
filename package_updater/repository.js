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

const simplegit = require('simple-git');
const colors = require('colors/safe');

function Repository(directory, githubAPIRepository, largestVersion, packageJSON) {
    'use strict';

    this.directory = directory;
    this.githubAPIRepository = githubAPIRepository;
    this.simplegitRepository = simplegit(directory);
    this.largestVersion = largestVersion;
    this.packageJSON = packageJSON;
}
module.exports = Repository;

const gittags = require('git-tags');
const gitConfig = require('git-config');
const spmHandler = require( __dirname + '/spmHandler.js');

Repository.prototype.getName = function() {
    'use strict';
    return this.githubAPIRepository.name;
};

Repository.prototype.getDirectory = function() {
    'use strict';
    return this.directory;
};

Repository.prototype.getCloneURL = function() {
    'use strict';
    return this.githubAPIRepository.clone_url;
};

Repository.log = function(repositories, title, color, doNotPrintEmpty) {
    'use strict';
    const colorToUse = color? color : colors.grey;
    if (repositories.length > 0 || !doNotPrintEmpty) {
        console.log(colorToUse(title + ':'));
    }
    repositories.forEach(repository => console.log(colorToUse(`\t${repository.getName()}`)));
};


// @param repository - githubAPI repository
// @param callback callback(error, repository)

Repository.create = function(workDirectory, githubAPIRepository, callback) {
    'use strict';

    const directory = Repository.getDirectory(workDirectory, githubAPIRepository);
    gittags.latest(directory, (error, largestVersion) => {
        if (error) {
            return callback(error);
        }
        console.log(`last tag in ${githubAPIRepository.name} is ${largestVersion}`);
        spmHandler.getPackageAsJSON(directory, (error, packageJSON) => {
            callback(error, new Repository(directory, githubAPIRepository,
                                           largestVersion, packageJSON));
        });
    });
};

Repository.prototype.createBranch = function(branchName, callback) {
    'use strict';
    this.simplegitRepository.checkoutBranch(branchName, 'master', callback);
};

Repository.prototype.push = function(branchName, callback) {
    'use strict';
    this.simplegitRepository.push('origin', branchName, callback);
};

Repository.prototype.pushTags = function(callback) {
    'use strict';
    this.simplegitRepository.pushTags('origin', callback);
};

Repository.prototype.addTag = function(tag,callback) {
    'use strict';
    this.simplegitRepository.addTag(tag, callback);
};

Repository.getCredentials = function(callback) {
    'use strict';
    gitConfig((error, config) => {
        if (error || !config || !config.user) {
            console.log('Unable to get credentials');
            return callback({name: 'UNKNOWN', email: 'UNKNOWN'});
        }
        callback({name: config.user.name, email: config.user.email});
    });
};

Repository.getDirectory = function(workDirectory, githubRepository) {
    'use strict';
    return workDirectory + '/' + githubRepository.name + '/';
};

Repository.prototype.wasChangedAfterVersion = function(version, callback) {
    'use strict';
    this.simplegitRepository.diff([version], (error, difference) =>
                                  callback(error, !error && difference));
};

Repository.prototype.hasBranch = function(branchName, callback) {
    'use strict';
    this.simplegitRepository.branch((error, branchSummary) =>
                                    callback(error, !error && branchSummary.branches[branchName]));
};
