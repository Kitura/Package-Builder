# Package-Builder

This repository contains build and utility scripts used for continuous integration builds on the Travis CI environment. It also contains a very useful Makefile for building Swift packages that our team develops.

Features of this repository:

1.  If you need a specific verison of Swift to be used, place that version in a .swift-version file in the root level of your repository
2.  If you need a special swift compile line, place a .swift-build-linux or .swift-build-macOS file in the root level of your repository with the exact compile line for the OS needed.

