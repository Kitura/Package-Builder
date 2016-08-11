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

const fs = require('fs');
const GithubAPI = require('github');
const untildify = require('untildify');

function Github(organizationName) {
    'use strict';
    this.organizationName = organizationName;
    this.githubAPI = new GithubAPI({
        protocol: "https",
        host: "api.github.com",
        Promise: require('bluebird'),
        followRedirects: false,
        debug: false,
        timeout: 5000
    });
    this.user = null;
}
module.exports = Github;

Github.prototype.authenticate = function(callback) {
    'use strict';
    var self = this;

    fs.readFile(untildify('~/.ssh/package_updater_github_token.txt'), 'utf8',
         (error, token) => {
             if (error) {
                 callback(error, null);
             }

             self.githubAPI.authenticate({type: "oauth", token: token.trim()});
             self.githubAPI.users.get({}, (error, user) => {
                 self.user = user;
                 callback(null, self);
             });
         });
};

Github.prototype.getUserName = function() {
    'use strict';
    return this.user.login;
};

Github.prototype.getIBMSwiftRepositories = function(callback) {
    'use strict';
    const self = this;
    this.githubAPI.repos.getForOrg({
        org: self.organizationName,
        type: "all",
        per_page: 300
    }, callback);
};

Github.prototype.submitPRToMaster = function(repositoryName, title, branchName, callback) {
    'use strict';

    const self = this;
    this.githubAPI.pullRequests.create({
        user: self.organizationName,
        repo: repositoryName,
        title: title,
        head: branchName,
        base: 'master',
    }, callback);
};
