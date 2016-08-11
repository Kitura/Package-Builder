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

const readline = require('readline');
const fs = require('fs');
const async = require('async');

function readRepositoriesFromFile(file, callback) {
    'use strict';

    var repositoriesToUpdate = {};

    const repositoriesToUpdateReader = readline.createInterface({
        input: fs.createReadStream(file)
    });

    repositoriesToUpdateReader.on('line', line => {
        line = line.split('#')[0];
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

function getRepositoriesFromFile(file, github, callback) {
    'use strict';
    async.parallel({
        repositories: async.apply(readRepositoriesFromFile, file),
        ibmSwiftRepositories: github.getIBMSwiftRepositories.bind(github)
    }, (error, result) => {
        if (error) {
            return callback(error);
        }
        const repositoriesToHandle = result.ibmSwiftRepositories.filter(repository => {
            return result.repositories[repository.name];
        });

        callback(null, repositoriesToHandle);
    });
}

module.exports = getRepositoriesFromFile;
