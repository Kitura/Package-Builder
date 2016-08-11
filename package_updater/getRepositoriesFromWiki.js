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
const readline = require('readline');
const request = require('request');

function readRepositoriesFromWiki(wikiURL, callback) {
    'use strict';

    var repositoriesToUpdate = {};

    const repositoriesToUpdateReader = readline.createInterface({
        input: request(wikiURL + '.md')
    });

    repositoriesToUpdateReader.on('line', line => {
        line = line.split('*')[1];
        if (!line) {
            return;
        }
        line = line.trim();
        if (!line) {
            return;
        }
        repositoriesToUpdate[line] = true;
    });

    repositoriesToUpdateReader.on('close', () => {
        callback(null, repositoriesToUpdate);
    });
}

function getRepositoriesFromWiki(wikiURL, github, callback) {
    'use strict';
    async.parallel({
        repositoriesToUpdate: async.apply(readRepositoriesFromWiki, wikiURL),
        ibmSwiftRepositories: github.getIBMSwiftRepositories.bind(github)
    }, (error, result) => {
        if (error) {
            return callback(error);
        }
        const repositoriesToHandle = result.ibmSwiftRepositories.filter(repository => {
            return result.repositoriesToUpdate[repository.html_url];
        });

        callback(null, repositoriesToHandle);
    });
}

module.exports = getRepositoriesFromWiki;
