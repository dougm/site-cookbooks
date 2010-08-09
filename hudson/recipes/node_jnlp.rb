#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Recipe:: node_jnlp
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

group node[:hudson][:node][:user] do
end

user node[:hudson][:node][:user] do
  comment "Hudson CI node (jnlp)"
  gid node[:hudson][:node][:user]
  home node[:hudson][:node][:home]
end

directory node[:hudson][:node][:home] do
  action :create
  owner node[:hudson][:node][:user]
  group node[:hudson][:node][:user]
end

hudson_node node[:hudson][:node][:name] do
  description  node[:hudson][:node][:description]
  executors    node[:hudson][:node][:executors]
  remote_fs    node[:hudson][:node][:home]
  labels       node[:hudson][:node][:labels]
  mode         node[:hudson][:node][:mode]
  launcher     "jnlp"
  mode         node[:hudson][:node][:mode]
  availability node[:hudson][:node][:availability]
end

remote_file "#{node[:hudson][:node][:home]}/slave.jar" do
  source "#{node[:hudson][:server][:url]}/jnlpJars/slave.jar"
  notifies :restart, resources(:service => service_name), :immediately
end

#XXX runit_service or similar
