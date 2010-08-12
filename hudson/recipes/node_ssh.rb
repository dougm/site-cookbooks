#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Recipe:: node_ssh
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

unless node[:hudson][:server][:pubkey]
  host = node[:hudson][:server][:host]
  if host == node[:fqdn]
    host = URI.parse(node[:hudson][:server][:url]).host
  end
  hudson_node = search(:node, "fqdn:#{host}").first
  node.set[:hudson][:server][:pubkey] = hudson_node[:hudson][:server][:pubkey]
end

group node[:hudson][:node][:user] do
end

user node[:hudson][:node][:user] do
  comment "Hudson CI node (ssh)"
  gid node[:hudson][:node][:user]
  home node[:hudson][:node][:home]
  shell "/bin/sh"
end

directory node[:hudson][:node][:home] do
  action :create
  owner node[:hudson][:node][:user]
  group node[:hudson][:node][:user]
end

directory "#{node[:hudson][:node][:home]}/.ssh" do
  action :create
  mode 0700
  owner node[:hudson][:node][:user]
  group node[:hudson][:node][:user]
end

file "#{node[:hudson][:node][:home]}/.ssh/authorized_keys" do
  action :create
  mode 0600
  owner node[:hudson][:node][:user]
  group node[:hudson][:node][:user]
  content node[:hudson][:server][:pubkey]
end

hudson_node node[:hudson][:node][:name] do
  description  node[:hudson][:node][:description]
  executors    node[:hudson][:node][:executors]
  remote_fs    node[:hudson][:node][:home]
  labels       node[:hudson][:node][:labels]
  mode         node[:hudson][:node][:mode]
  launcher     "ssh"
  mode         node[:hudson][:node][:mode]
  availability node[:hudson][:node][:availability]
  env          node[:hudson][:node][:env]
  #ssh options
  host         node[:hudson][:node][:ssh_host]
  port         node[:hudson][:node][:ssh_port]
  username     node[:hudson][:node][:ssh_user]
  password     node[:hudson][:node][:ssh_pass]
  private_key  node[:hudson][:node][:ssh_private_key]
  jvm_options  node[:hudson][:node][:jvm_options]
end
