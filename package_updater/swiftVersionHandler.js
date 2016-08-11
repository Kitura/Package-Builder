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

const SWIFT_VERSION_FILE = '.swift-version';

function SwiftVersionHandler(repository, swiftVersion) {
    'use strict';

    this.swiftVersionPath = repository.getDirectory() + SWIFT_VERSION_FILE;
    this.swiftVersion = swiftVersion;
    this.simplegitRepository = repository.simplegitRepository;
}

module.exports = SwiftVersionHandler;

const fs = require('fs');

// @param repository - simplegit repository
function commitSwiftVersion(repository, swiftVersion, callback) {
    'use strict';
    repository.add('.swift-version').commit(swiftVersion, '.swift-version', {}, callback);
}

function readSwiftVersion(swiftVersionPath, callback) {
    'use strict';

    fs.access(swiftVersionPath, error => {
        if (error) {
            return callback(null, "");
        }
        fs.readFile(swiftVersionPath, (error, data) => {
            if (error) {
                return callback(error);
            }
            return callback(null, data);
        });
    });
}

function writeSwiftVersion(swiftVersionPath, swiftVersion, callback) {
    'use strict';

    fs.writeFile(swiftVersionPath, swiftVersion + '\n', error => {
        if (error) {
            callback(error);
        }
        callback(null);
    });
}

SwiftVersionHandler.prototype.updateSwiftVersion = function(callback) {
    'use strict';

    const self = this;
    readSwiftVersion(self.swiftVersionPath, (error, currentSwiftVersion) => {
        if (error) {
            callback(error);
        }
        if (self.swiftVersion === currentSwiftVersion) {
            return callback(null);
        }
        writeSwiftVersion(self.swiftVersionPath, self.swiftVersion, error => {
            if (error) {
                callback(error);
            }
            commitSwiftVersion(self.simplegitRepository, self.swiftVersion, callback);
        });
    });
};
