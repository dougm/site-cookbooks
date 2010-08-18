#
# Cookbook Name:: perforce
# Recipe:: default
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

case node[:os]
when "linux"
  if node[:kernel][:machine] == "x86_64"
    p4 = "bin.linux26x86_64/p4"
  else
    p4 = "bin.linux26x86/p4"
  end
when "darwin"
  p4 = "bin.macosx104u/p4"
when "windows"
  p4 = "bin.ntx86/p4.exe"
when "solaris2"
  p4 = "bin.solaris10x86/p4"
end

remote_file "#{node[:perforce][:bindir]}/#{File.basename(p4)}" do
  action :create_if_missing
  source "#{node[:perforce][:mirror]}/#{node[:perforce][:version]}/#{p4}"
  mode "0555" unless node[:os] == "windows"
end
