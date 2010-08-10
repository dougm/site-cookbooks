#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: perl
#
# Copyright 2010, VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

msi = File.basename(node[:perl][:release])
dir = "#{node[:perl][:dir]}\\Perl"
dst = "#{dir}\\#{msi}"

directory dir do
  action :create
end

remote_file dst do
  source "#{node[:perl][:mirror]}/ActivePerl/releases/#{node[:perl][:release]}"
  not_if { File.exists?(dst) }
end

execute "install #{msi}" do
  command "msiexec /qn /i #{dst} TARGETDIR=#{node[:perl][:dir]} PERL_PATH=Yes"
  not_if { File.exists?("#{dir}/bin/perl.exe") }
end
