#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: xemacs
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

exe = "XEmacs_Setup_#{node[:xemacs][:release]}.exe"

dst = "#{node[:xemacs][:dir]}\\#{exe}"

directory node[:xemacs][:dir] do
  action :create
end

remote_file dst do
  source "#{node[:xemacs][:mirror]}/xemacs/binaries/win32/InnoSetup/#{exe}"
  not_if { File.exists?(dst) }
end

execute "install #{exe}" do
  command "#{dst} /VERYSILENT /TYPE=#{node[:xemacs][:type]} /DIR=#{node[:xemacs][:dir]}"
  not_if { File.directory?("#{node[:xemacs][:dir]}\\XEmacs-#{node[:xemacs][:release]}") }
end
