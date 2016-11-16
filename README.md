# Package-Builder

This repository contains build and utility scripts used for continuous integration builds on the Travis CI environment. It also contains a very useful Makefile for building Swift packages that our team develops.

## Advanced capabilities provided by Package-Builder include:

1.  If you need a specific version of Swift to build and compile your repo, you should specify that version in a `.swift-version` file in the root level of your repository.
2.  If you need a custom command for compiling your Swift package, you should include a `.swift-build-linux` or `.swift-build-macOS` file in the root level of your repository and specify in it the exact compilation command for the corresponding platform.

