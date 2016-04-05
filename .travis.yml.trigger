# .travis.yml for Kitura Swift Packages

sudo: true

# whitelist
branches:
  only:
    - master
    - develop

before_install:
<<<<<<< a58a453eb5aa075236b2639f5d35a82ec2b0adb0
- git submodule init
- git submodule update
- cd Kitura-Build && git checkout master && cd $TRAVIS_BUILD_DIR
=======
  - git submodule init
  - git submodule update
  - cd Kitura-Build && git checkout $TRAVIS_BRANCH && cd $TRAVIS_BUILD_DIR
>>>>>>> IBM-Swift/Kitura#288 Updated naming

script:
  - echo "About to trigger build for the Kitura repository..."
  - cd Kitura-Build && ./kitura-build-trigger.sh $TRAVIS_BRANCH $TRAVIS_TOKEN
  - echo "Request to build Kitura sent!"
