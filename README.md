[![Build Status](https://travis-ci.org/IBM-Swift/Package-Builder.svg?branch=master)](https://travis-ci.org/IBM-Swift/Package-Builder)

# Package-Builder

This repository contains build and utility scripts used for continuous integration builds on the Travis CI environment. It offers many extension points for customizing builds, tests, and versions.

## Build Prerequities

Package-Builder is intended to be used as part of Travis CI tests, and will operate on both Ubuntu 14.04 and macOS.  At minimum, it will look something like this:

```
$ cat .travis.yml

matrix:
  include:
    - os: linux
      dist: trusty
      sudo: required
    - os: osx
      osx_image: xcode8.2
      sudo: required

before_install:
  - git clone https://github.com/IBM-Swift/Package-Builder.git

script:
  - ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR
```

Install any system-level dependencies or custom credentials in the `before_install` section of the Travis script so that the application files and structure are complete for compilation and testing.

## CodeCov
CodeCov is used in Package-Builder to determine how much test coverage exists in the packages being built. Codecov allows us determine which methods and statements in our code are not currently covered by the automated test cases included in the project.

## Custom SwiftLint
Ensure that your team's coding standard conventions are being met by providing your own `.swiftlint.yml` in the root directory with the specified rules to be run by Package-Builder.

## Using different Swift versions and snapshots
Package-Builder uses the most recent release version of Swift - `3.0.2`.  If you need a specific version of Swift to build and compile your repo, you should specify that version in a `.swift-version` file in the root level of your repository.  Valid contents of this file include `RELEASE` and `DEVELOPMENT` snapshots from Swift.org, as well as pre-release development snapshots.  

```
$ cat .swift-version

swift-DEVELOPMENT-SNAPSHOT-2017-02-14-a
```

## Custom Build & Test Commands
If you need a custom command for compiling your Swift package, you should include a `.swift-build-linux` or `.swift-build-macOS` file in the root level of your repository and specify in it the exact compilation command for the corresponding platform. If you need a custom command for testing your Swift package, you should include a `.swift-test-linux` or `.swift-test-macOS` file in the root level of your repository and specify in it the exact testing command for the corresponding platform.
```
$ cat .swift-build-linux

swift build -Xcc -I/usr/include/postgresql
```

### Custom Xcode project generation
Following the same naming convention as above, a `.swift-xcodeproj-linux` and `.swift-xcodeproj-macOS` file can be provided that contain a custom `swift package generate-xcodeproj` command.

### Custom configuration for executing tests
Sometimes, a dependency must be set up in order for the testing process to be complete.  In order to leverage this extension point, include a `before_tests.sh` or `after_tests.sh` file for each operation system that requires special set up. For example, if custom installation was needed, there would be three `before_tests.sh` files, each in a `linux`, `osx`, and `common` directory from the root.  The `common/before_tests.sh` is executed after the operating system specific `before_tests.sh` but `common/after_tests.sh` before the `after_tests.sh` for each operating system.

See an example of [setting up Redis](https://github.com/IBM-Swift/Kitura-CI/tree/master/Kitura-redis) for testing purposes using this feature.

## Troubleshooting
If there is a crash, Package-Builder will perform a log dump to provide meaningful diagnosis of where the failure has occurred.
