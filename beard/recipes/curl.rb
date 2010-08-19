#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: beard
# Recipe:: curl
#
# Copyright 2010, VMware, Inc
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

tgz = "curl-#{node[:curl][:version]}.tar.gz"
dst = File.join(Chef::Config[:file_cache_path], tgz)

remote_file dst do
  source "#{node[:curl][:mirror]}/#{tgz}"
  not_if { File.exists?(dst) }
end

bash "install curl #{node[:curl][:version]}" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    gunzip < #{tgz} | tar -xf -
    cd curl-#{node[:curl][:version]}
    ./configure #{node[:curl][:configure]} && #{node[:curl][:make]} install
  EOH
  not_if { ::File.exists?("#{node[:curl][:prefix]}/bin/curl") }
end
