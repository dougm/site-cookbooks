#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: chef_client
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

#knife windows bootstrap fqdn -r windows::chef_client

home = 'c:\chef\bin'
chef_exe = "#{home}\\chef-client.exe"
service_name = "chefclient"

directory home

directory 'c:\chef\log'

template "#{home}/chef-client.xml" do
  source "chef-client.xml"
end

# TODO (mat): Running install on winsw-1.9 during first boostrap exits on 42.
#             Try 1.11 (From hudson team)
# NOTE: This project lives at https://github.com/kohsuke/winsw
remote_file chef_exe do
  source "http://download.java.net/maven/2/com/sun/winsw/winsw/1.9/winsw-1.9-bin.exe"
  not_if { File.exists?(chef_exe) }
end

execute "#{chef_exe} install" do
  cwd home
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => service_name}).nil? }
end

service service_name do
  action :start
end
