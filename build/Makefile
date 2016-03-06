# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Makefile

UNAME = ${shell uname}

CC_FLAGS = -Xcc -fblocks

ifeq ($(UNAME), Darwin)
SWIFTC_FLAGS =  -Xswiftc -I/usr/local/include
LINKER_FLAGS = -Xlinker -L/usr/local/lib
endif

all: build

build:
	@echo Performing build on $(UNAME)
ifeq ($(UNAME), Linux)
	swift build --fetch
	swift build $(CC_FLAGS) $(SWIFTC_FLAGS) $(LINKER_FLAGS) `bash Kitura-CI/build//make_ccflags_for_module_maps`
else
	swift build $(CC_FLAGS) $(SWIFTC_FLAGS) $(LINKER_FLAGS)
endif

test: build
	swift test

run: build
	./.build/debug/KituraSample

clean:
	rm -rf .build Packages

.PHONY: clean build
