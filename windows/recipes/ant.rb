#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: ant
#
# Copyright 2010, VMware, Inc.
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

directory node[:ant][:dir] do
  action :create
  recursive true
end

dir = "apache-ant-#{node[:ant][:release]}"
zip = "#{dir}-bin.zip"
dst = "#{node[:ant][:dir]}\\#{zip}"
home = "#{node[:ant][:dir]}\\#{dir}"
junit = "#{home}\\lib\\#{File.basename(node[:ant][:junit_jar])}"

remote_file dst do
  source "#{node[:ant][:mirror]}/#{zip}"
  not_if { File.exists?(dst) }
end

windows_unzip dst do
  force true
  path node[:ant][:dir]
  not_if { File.exists?("#{node[:ant][:dir]}\\#{dir}\\bin\\ant.bat") }
end

remote_file junit do
  source node[:ant][:junit_jar]
  not_if { File.exists?(junit) }
end

env "ANT_HOME" do
  value home
end

env "PATH" do
  action :modify
  delim File::PATH_SEPARATOR
  value '%ANT_HOME%\bin'
end

