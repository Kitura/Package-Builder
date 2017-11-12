[![Build Status](https://travis-ci.org/IBM-Swift/Package-Builder.svg?branch=develop)](https://travis-ci.org/IBM-Swift/Package-Builder)

# Package-Builder

This repository contains build and utility scripts used for continuous integration builds on the Travis CI environment. It offers many extension points for customizing builds and tests.

## Build prerequisites

Package-Builder is intended to be used as part of Travis CI tests, and will operate on both Ubuntu 14.04 and macOS.  At a minimum, the `.travis.yml` file of your application will look something like this:

```
$ cat .travis.yml

matrix:
  include:
    - os: linux
      dist: trusty
      sudo: required
    - os: osx
      osx_image: xcode9
      sudo: required

before_install:
  - git clone https://github.com/IBM-Swift/Package-Builder.git

script:
  - ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR
```

If you need to install system-level dependencies such as libmysqlclient-dev, you can do so in the `before_install` section of the `.travis.yml` file so that the Travis CI build environment is ready for compilation and testing of your Swift package.

### How to start the build-package.sh script
This script must be started form the folder that contains your Swift package. Also, please note that the `projectDir` argument passed to the script should be the directory of the whole repository. For most projects, this is the same as the folder that contains your Swift package, as shown in the example above. However, there are repositories where the Swift packaage is a sub-folder in the main project.

### Providing custom credentials
It is not uncommon for swift packages to need to connect to secure services, offerings, and middleware such as databases.  To do this, credentials are needed from properties files.  To ensure the security of these credentials, many teams use private repositories to store these credentials while their public ones contain dummy files like the one below:

```
$ cat configuration.json

{
  ...
  "credentials": {
      "url": "<url>",
      "name": "<name>",
      "password": "<password>"      
    }
  ...
}
```

The true credentials, show below, should be stored in a private repository:

```
$ cat configuration.json

{
  ...
  "credentials": {
      "url": "api.ng.bluemix.net/v2/authenticate",
      "name": "sample@us.ibm.com",
      "password": "passw0rd"      
    }
  ...
}
```

In order to meet this need, Package-Builder will copy and overwrite these dummy files with the credentials from the private repository.  To leverage this functionality, be sure to clone the credentials in the `before_install` section, and then use the following in your `.travis.yml`, pointing towards the folder where the cloned credentials exist:

```
script:
  - ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR -credentialsDir <path to credentials>
```

## Codecov
[Codecov](https://codecov.io/) is used in Package-Builder to determine how much test coverage exists in your code. Codecov allows us to determine which methods and statements in our code are not currently covered by the automated test cases included in the project. Codecov performs its analysis by generating an Xcode project.

For example, see the [current test coverage](https://codecov.io/gh/IBM-Swift/Swift-cfenv) for the [Swift-cfenv](https://github.com/IBM-Swift/Swift-cfenv) package.

![Codecov Report](/img/codecov-swift-cfenv-1024x768.png?raw=true "Code Coverage Report")

Please note that Codecov is only leveraged when executing builds on the macOS platform. 

### Custom Xcode project generation
If for Codecov, you need a custom command to generate the Xcode project for your Swift package, you should include a `.swift-xcodeproj` file that contains your custom `swift package generate-xcodeproj` command.

### Custom code coverage
If you need to run a custom command to generate code coverage for your Swift package, you should include a `.swift-codecov` file that contains your command.

## Custom SwiftLint
[SwiftLint](https://github.com/realm/SwiftLint) is a tool to enforce Swift style and conventions. Ensure that your team's coding standard conventions are being met by providing your own `.swiftlint.yml` in the root directory with the specified rules to be run by Package-Builder.  For now each project should provide their own `.swiftlint.yml` file to adhere to your preferences.  A default may be used in the future, but as of now no SwiftLint operations are performed unless a `.swiftlint.yml` file exists.

Please note that SwiftLint is only leveraged when executing builds on the macOS platform.

## Using different Swift versions and snapshots
Package-Builder uses, by default, the most recent release version of Swift, which at the time of writing is `4.0.2`. If you need a specific version of Swift to build and compile your repo, you should specify that version in a `.swift-version` file in the root level of your repository.  Valid contents of this file include release and development snapshots from [Swift.org](https://swift.org/).

```
$ cat .swift-version

swift-DEVELOPMENT-SNAPSHOT-2017-02-14-a
```
### Testing with multiple Swift versions
To test your package using a different version of Swift than the one specified in your `.swift-version` file, simply add the `SWIFT_SNAPSHOT` environment variable to your `.travis.yml` file in each one of the entries under the matrix section as shown below:
```
$ cat .travis.yml

matrix:
  include:
    - os: linux
      dist: trusty
      sudo: required
    - os: linux
      dist: trusty
      sudo: required
      env: SWIFT_SNAPSHOT=3.1.1

before_install:
  - git clone https://github.com/IBM-Swift/Package-Builder.git

script:
  - ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR
```

In this example above, the first build uses the version specified in the `.swift-version` of the project, or the default version supported by Package-Builder.  The second one declares a `SWIFT_SNAPSHOT` environment variable, which overrides the default and `.swift-version` versions for that build.

## Custom build and test commands
If you need a custom command for **compiling** your Swift package, you should include a `.swift-build-linux` or `.swift-build-macOS` file in the root level of your repository and specify in it the exact compilation command for the corresponding platform.

```
$ cat .swift-build-linux

swift build -Xcc -I/usr/include/postgresql
```

If you need a custom command for **testing** your Swift package, you should include a `.swift-test-linux` or `.swift-test-macOS` file in the root level of your repository and specify in it the exact testing command for the corresponding platform.

```
$ cat .swift-test-linux

swift test -Xcc -I/usr/include/postgresql
```

### Custom configuration for executing tests
Sometimes, a dependency must be set up before the testing process can begin. You may also have the need to execute certain actions after your tests have completed (e.g. shutting down a server). Package-Builder provides an extension point to do this; you can include a `before_tests.sh` and/or a `after_tests.sh` file containing the commands to be executed before and after the tests.

These files should be placed in a folder structure that matches the outline shown below (see the `linux`, `osx`, and `common` folders):

![File Structure](/img/file_screenshot.jpg?raw=true "Sample File Structure")

*Before Tests:* The `linux/before_tests.sh` and `osx/before_tests.sh` scripts will be executed first if present, followed by `common/before_tests.sh`. Once complete, the tests will commence.

*After Tests:* After the tests are performed, `common/after_tests.sh` is executed first, followed by `linux/after_tests.sh` or `osx/after_tests.sh`.

## Troubleshooting
If there is a crash during the execution of test cases, Package-Builder will perform a log dump to provide meaningful diagnosis of where the failure has occurred.
