#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Recipe:: node_windows
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

home = node[:hudson][:node][:home]
url  = node[:hudson][:server][:url]

hudson_exe = "#{home}\\hudson-slave.exe"
service_name = "hudsonslave"

directory home do
  action :create
end

env "HUDSON_HOME" do
  action :create
  value home
end

env "HUDSON_URL" do
  action :create
  value url
end

template "#{home}/hudson-slave.xml" do
  source "hudson-slave.xml"
  variables(:hudson_home => home,
            :jnlp_url => "#{url}/computer/#{node[:hudson][:node][:name]}/slave-agent.jnlp")
end

#XXX how-to get this directly from the hudson server?
remote_file hudson_exe do
  source "http://maven.dyndns.org/2/com/sun/winsw/winsw/1.8/winsw-1.8-bin.exe"
  not_if { File.exists?(hudson_exe) }
end

execute "#{hudson_exe} install" do
  cwd home
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => service_name}).nil? }
end

service service_name do
  action :nothing
end

hudson_node node[:hudson][:node][:name] do
  description  node[:hudson][:node][:description]
  executors    node[:hudson][:node][:executors]
  remote_fs    node[:hudson][:node][:home]
  labels       node[:hudson][:node][:labels]
  mode         node[:hudson][:node][:mode]
  launcher     node[:hudson][:node][:launcher]
  mode         node[:hudson][:node][:mode]
  availability node[:hudson][:node][:availability]
end

remote_file "#{home}\\slave.jar" do
  source "#{url}/jnlpJars/slave.jar"
  notifies :restart, resources(:service => service_name), :immediately
end

service service_name do
  action :start
end
