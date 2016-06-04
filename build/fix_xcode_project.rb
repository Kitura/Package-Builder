#/**
#* Copyright IBM Corporation 2016
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#**/
gem 'xcodeproj'
require 'xcodeproj'

project_file = ARGV.first;

project = Xcodeproj::Project.open(project_file + ".xcodeproj");

targets_to_fix = project.targets.select { |target| target.name == 'Kitura' || target.name == 'KituraNet' }
targets_to_fix.each do |target|
  puts "handling #{target}"
  target.build_configurations.each do |build_configuration|
    build_configuration.build_settings['LIBRARY_SEARCH_PATHS'] = '$(SRCROOT)/.build/debug'
  end
end

project.save
