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

const exec = require('child_process').exec;
const async = require('async');
const replace = require('replace-in-file');
const semver = require('semver');
const fs = require('fs');

function getPackageAsJSON(repositoryDirectory, callback) {
    'use strict';

    const swiftDumpPackageCommand =
         `swift package dump-package --input ${repositoryDirectory}/Package.swift`;

    exec(swiftDumpPackageCommand, (error, stdout, stderr) => {
        if (error) {
            return callback(error, null);
        }
        if (stderr) {
            console.warn(stderr);
        }

        callback(null, JSON.parse(stdout));
    });
}

function hasDependencyWithVersions(packageJSON, dependencyURL, version) {
    'use strict';
    return packageJSON.dependencies.some(dependency =>
        dependency.url === dependencyURL && dependency.version.lowerBound === version);
}

function getNotUpdatedPackageError(repositoryDirectory) {
    'use strict';
    return `Did not manage to update Package.swift in ${repositoryDirectory}.\n` +
        'Verify that the dependency is in format .Package(url: <https url>,' +
        '  majorVersion: <major>, minor: <minor>), exactly without redundant whitespace.';
}

function verifyThePackageWasUpdated(repositoryDirectory, dependencyURL, version, callback) {
    'use strict';

    getPackageAsJSON(repositoryDirectory, (error, packageJSON) => {
        if (error) {
            callback(error);
        }
        if (hasDependencyWithVersions(packageJSON, dependencyURL, version)) {
            callback(null);
        } else {
            callback(getNotUpdatedPackageError(repositoryDirectory));
        }
    });
}

function updateDependency(repositoryDirectory, dependencyURL, version, callback) {
    'use strict';

    const major = semver.major(version);
    const minor = semver.minor(version);

    console.log(`updating dependency of ${dependencyURL} to version ${version},` +
                ` major ${major}, minor ${minor}`);
    replace({
        replace: new RegExp('\\.Package\\(url: \\"' + dependencyURL +
                        '\\", majorVersion: [0-9]+, minor: [0-9]+\\)','g'),
        with: '.Package(url: "' + dependencyURL +
              '", majorVersion: ' + major + ', minor: ' + minor + ')',
        files: repositoryDirectory + 'Package.swift'
    }, (error, changedFiles) => {
        if (error) {
            callback(error);
        }

        if (changedFiles < 1) {
            return callback(getNotUpdatedPackageError(repositoryDirectory));
        }
        verifyThePackageWasUpdated(repositoryDirectory, dependencyURL, version, callback);
    });
}

function updateDependencies(repositoryDirectory, packageJSON, versions, callback) {
    'use strict';

    console.log(`update dependencies in ${repositoryDirectory}`);

    if (packageJSON.dependencies.length === 0) {
        return callback(null, []);
    }

    async.mapSeries(packageJSON.dependencies, (dependency, callback) => {
        const newVersion = versions[dependency.url];
        if (newVersion) {
            return updateDependency(repositoryDirectory, dependency.url, newVersion,
                 error => callback(error, { dependencyURL: dependency.url, version: newVersion}));
        }
        callback(null, null);
    }, callback);
}

function hasPackageDotSwift(directory, callback) {
    'use strict';
    fs.access(directory + 'Package.swift', error => callback(null, !error));
}

module.exports = {getPackageAsJSON: getPackageAsJSON, updateDependencies: updateDependencies,
                  hasPackageDotSwift: hasPackageDotSwift};
