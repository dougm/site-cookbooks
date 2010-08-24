#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: macrdc
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

#generate ~/Documents/RDC Connections/*.rdp for each windows node to use with:
#http://www.microsoft.com/mac/products/remote-desktop/default.mspx on a Mac

directory node[:macrdc][:connections_dir] do
  action :create
  recursive true
end

nodes = node[:macrdc][:nodes] || search(:node, "os:windows")

nodes.each do |rdc|
  begin
    connection = Socket.gethostbyname(rdc[:fqdn]).first
  rescue
    connection = rdc[:ipaddress]
  end
  template "#{node[:macrdc][:connections_dir]}/#{rdc[:hostname].downcase}.rdp" do
    source "default.rdp"
    variables(:connection => connection)
  end
end

#install the RDC app
dst = "#{ENV['HOME']}/Downloads/#{File.basename(node[:macrdc][:dmg_path])}"
remote_file dst do
  source "#{node[:macrdc][:mirror]}/#{node[:macrdc][:dmg_path]}"
  not_if { File.exists?(dst) }
end

bash "install RDC.dmg" do
  not_if { File.exists?("#{node[:macrdc][:target]}/Remote Desktop Connection.app") }
  code <<-EOH
hdiutil attach #{dst}
sudo installer -pkg "/Volumes/Remote Desktop Connection/Remote Desktop Connection.mpkg"  -target "#{node[:macrdc][:target]}"
hdiutil detach "/Volumes/Remote Desktop Connection"
EOH
end
