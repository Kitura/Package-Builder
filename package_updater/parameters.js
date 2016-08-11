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

const KITURA_VERSION_PARAMETER_INDEX = 2;
const SWIFT_VERSION_PARAMETER_INDEX = 3;
const READ_FROM_PARAMETER_INDEX = 4;

function Parameters() {
    'use strict';

    this.swiftVersion = null;
    this.kituraVersion = null;
}
module.exports = Parameters;

const readline = require('readline');
const async = require('async');
const colors = require('colors/safe');

function getParameterFromUser(question, callback) {
    'use strict';

    const readlineInterface = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    readlineInterface.question(question + ' > ',
                               function(answer) {
                                   readlineInterface.close();
                                   callback(null, answer.trim());
                               });
}

function getParameter(parameterNumber, question, callback) {
    'use strict';

    if (process.argv.length > parameterNumber) {
        callback(null, process.argv[parameterNumber]);
    }
    else {
        getParameterFromUser(question, callback);
    }
}

function getVerifiedParameter(parameterNumber, question, verify, callback) {
    'use strict';

    var parameter = process.argv[parameterNumber];

    function getParameter(callback) {
        getParameterFromUser(question, (error, answer) => { parameter = answer; callback(null);});
    }

    async.until(() => verify(parameter), getParameter, () => callback(null, parameter));
}

function getBooleanChoiceParameter(parameterNumber, question, choice1, choice2, color, callback) {
    'use strict';
    getVerifiedParameter(parameterNumber,
                         color(question + ` [${choice1}|${choice2}]`),
                         answer => answer === choice1 || answer === choice2,
                         (error, answer) => callback(error, answer === choice1));
}

function getBooleanParameter(parameterNumber, question, color, callback) {
    'use strict';
    getBooleanChoiceParameter(parameterNumber, question, 'Yes', 'No', color, callback);
}


function getKituraVersion(callback) {
    'use strict';

    return getVerifiedParameter(KITURA_VERSION_PARAMETER_INDEX,
        'Please enter Kitura version to set in format <major>.<minor>, e.g. 0.26',
        kituraVersion => /^(\d+)\.(\d+)$/.test(kituraVersion),
                                (error, kituraVersion) => callback(error, kituraVersion + '.0'));
}

function getSwiftVersion(callback) {
    'use strict';
    return getParameter(SWIFT_VERSION_PARAMETER_INDEX,
        'Please enter swift version, e.g. DEVELOPMENT-SNAPSHOT-2016-06-20-a', callback);
}

Parameters.prototype.read = function(callback) {
    'use strict';

    const self = this;

    getKituraVersion(function(error, kituraVersion) {
        if (error) {
            callback(error);
        }
        self.kituraVersion = kituraVersion;
        getSwiftVersion(function(error, swiftVersion) {
            self.swiftVersion = swiftVersion;
            callback(error);
        });
    });
};

Parameters.prototype.shouldReadFromWiki = function(callback) {
    'use strict';
    getBooleanChoiceParameter(READ_FROM_PARAMETER_INDEX,
        'Would you like to get the repositories from the wiki or from the whitelist?',
        'wiki', 'whitelist', colors.green, callback);
};

function createBooleanParameterFunction(name, parameterIndex, color, question) {
    'use strict';
    Parameters.prototype[name] = function(callback) {
        getBooleanParameter(parameterIndex, question, color, callback);
    };
}

var nextParameterIndex = Math.max(KITURA_VERSION_PARAMETER_INDEX, SWIFT_VERSION_PARAMETER_INDEX,
                                  READ_FROM_PARAMETER_INDEX) + 1;

createBooleanParameterFunction('shouldClone', nextParameterIndex++, colors.green,
                               'Would you like to clone the repositories?');
createBooleanParameterFunction('shouldUpdateLocally', nextParameterIndex++, colors.green,
                               'Would you like to update the cloned repositories locally?');
createBooleanParameterFunction('shouldPush', nextParameterIndex++, colors.red,
                               'Would you like to push the changes?');
createBooleanParameterFunction('shouldSubmitPRs', nextParameterIndex++, colors.red,
                               'Would you like to submit the PRs?');
