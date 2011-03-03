#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: gnuwin32
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

directory node[:gnuwin32][:dir] do
  action :create
  recursive true
end

["bin", "sbin"].map { |d| "#{node[:gnuwin32][:dir]}\\#{d}" }.each do |path|
  env "PATH" do
    action :modify
    delim File::PATH_SEPARATOR
    value path
  end
end

node[:gnuwin32][:packages].each do |package|
  url = "#{node[:gnuwin32][:mirror]}/#{package}.php"
  exe = "#{package}-setup.exe"
  dst = "#{node[:gnuwin32][:dir]}/#{exe}"

  execute exe do
    command "#{dst} /VERYSILENT /DIR=#{node[:gnuwin32][:dir]}"
    action :nothing
  end

  remote_file dst do
    source url
    not_if { File.exists?(dst) }
    notifies :run, resources(:execute => exe), :immediately
  end
end
