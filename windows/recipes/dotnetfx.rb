#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: dotnetfx
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

exe = ::File.basename(node[:dotnetfx][:url])
cmd = "c:\\chef\\tmp\\#{exe}"

remote_file exe do
  action :nothing
  source node[:dotnetfx][:url]
  path cmd
  backup false
end

execute exe do
  action :nothing
  command %Q(#{cmd} /q:a /c:"install /q")
end

ruby_block "installing Microsoft .NET Framework" do
  block {}
  only_if do
    require 'win32/registry'
    begin #need at least v2
      Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\Microsoft\.NETFramework').keys.select {|subkey|
        subkey =~ /^v[23]/
      }.empty?
    rescue
      true
    end
  end

  notifies :create_if_missing, resources(:remote_file => exe), :immediately
  notifies :run, resources(:execute => exe), :immediately
end
