#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: erlang
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

exe = "otp_win32_#{node[:erlang][:release]}.exe"
dst = "#{node[:erlang][:dir]}\\#{exe}"
erl = "#{node[:erlang][:dir]}\\bin\\erl.exe"

directory node[:erlang][:dir] do
  action :create
end

remote_file dst do
  source "#{node[:erlang][:mirror]}/#{exe}"
  not_if { File.exists?(dst) }
end

execute "install #{exe}" do
  command "#{dst} /S /NCRC /D=#{node[:erlang][:dir]}"
  not_if { File.exists?(erl) }
end

env "PATH" do
  action :modify
  delim File::PATH_SEPARATOR
  value "#{node[:erlang][:dir]}\\bin"
end
