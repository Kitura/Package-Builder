osName="linux"
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then osName="osx"; fi
export osName
export projectFolder=`pwd`
projectName="$(basename $projectFolder)"
export SWIFT_SNAPSHOT=swift-4.0
sudo apt-get -qq update > /dev/null
sudo apt-get -y -qq install clang lldb-3.8 libicu-dev libtool libcurl4-openssl-dev libbsd-dev build-essential libssl-dev uuid-dev tzdata libz-dev > /dev/null

# Environment vars
version=`lsb_release -d | awk '{print tolower($2) $3}'`
export UBUNTU_VERSION=`echo $version | awk -F. '{print $1"."$2}'`
export UBUNTU_VERSION_NO_DOTS=`echo $version | awk -F. '{print $1$2}'`

if [[ ${SWIFT_SNAPSHOT} =~ ^.*RELEASE.*$ ]]; then
    SNAPSHOT_TYPE=$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')
elif [[ ${SWIFT_SNAPSHOT} =~ ^swift-.*-DEVELOPMENT.*$ ]]; then
    SNAPSHOT_TYPE=${SWIFT_SNAPSHOT%-DEVELOPMENT*}-branch
elif [[ ${SWIFT_SNAPSHOT} =~ ^.*DEVELOPMENT.*$ ]]; then
    SNAPSHOT_TYPE=development
else
    SNAPSHOT_TYPE="$(echo "$SWIFT_SNAPSHOT" | tr '[:upper:]' '[:lower:]')-release"
    SWIFT_SNAPSHOT="${SWIFT_SNAPSHOT}-RELEASE"
fi

echo ">> Installing '${SWIFT_SNAPSHOT}'..."

# Install Swift compiler
cd $projectFolder
wget https://swift.org/builds/$SNAPSHOT_TYPE/$UBUNTU_VERSION_NO_DOTS/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
tar xzf $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz
export PATH=$projectFolder/$SWIFT_SNAPSHOT-$UBUNTU_VERSION/usr/bin:$PATH
rm $SWIFT_SNAPSHOT-$UBUNTU_VERSION.tar.gz

# Actions after Swift installation
git remote rm origin
git remote add origin https://SwiftDevOps:${GITHUB_TOKEN}@github.com/IBM-Swift/KituraKit
git fetch

swift package generate-xcodeproj
ruby --version
sudo gem install jazzy
cd /Users/travis/build/IBM-Swift/KituraContracts
jazzy
