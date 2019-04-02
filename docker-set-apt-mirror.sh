#!/bin/bash
#
# Change default mirror for Ubuntu Docker images to avoid slow primary archive.
# For now, this is a hard-coded alternative mirror selected based on currency
# and available bandwidth listed at https://launchpad.net/ubuntu/+archivemirrors

sed -i -e's:/[a-z]*.ubuntu.com:/ftp.halifax.rwth-aachen.de:g' /etc/apt/sources.list
