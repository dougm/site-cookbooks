#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: sysinternals
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

#install sysinternals and add to PATH
#optionally accept eula for all programs

bin = "#{node[:sysinternals][:dir]}\\bin"

directory bin do
  action :create
  recursive true
end

zip = "SysinternalsSuite.zip"
dst = "#{node[:sysinternals][:dir]}\\#{zip}"

remote_file dst do
  source "#{node[:sysinternals][:mirror]}/#{zip}"
  not_if { File.exists?(dst) }
end

windows_unzip dst do
  force true
  path bin
  not_if { File.exists?("#{bin}\\PsExec.exe") }
end

ruby_block "accept sysinternals eula" do
  only_if { node[:sysinternals][:accept_eula] }
  block { sysinternals_accept_eula(bin) }
end

env "PATH" do
  action :modify
  delim File::PATH_SEPARATOR
  value bin
end
