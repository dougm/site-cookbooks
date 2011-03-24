#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: maven
#
# Copyright 2011, VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

directory node[:maven][:dir] do
  action :create
  recursive true
end

dir = "apache-maven-#{node[:maven][:release]}"
zip = "#{dir}-bin.zip"
dst = "#{node[:maven][:dir]}\\#{zip}"
home = "#{node[:maven][:dir]}\\#{dir}"

remote_file dst do
  source "#{node[:maven][:mirror]}/#{zip}"
  not_if { File.exists?(dst) }
end

#XXX rubyzip fails to unzip apache-maven-2.2.1-bin.zip
#so fuckit, use jar to extract for now.
#windows_unzip dst do
#  force true
#  path node[:maven][:dir]
execute "jar -xf #{dst}" do
  cwd node[:maven][:dir]
  not_if { File.exists?("#{node[:maven][:dir]}\\#{dir}\\bin\\mvn.bat") }
end

env "M2_HOME" do
  value home
end

env "PATH" do
  action :modify
  delim File::PATH_SEPARATOR
  value '%M2_HOME%\bin'
end
