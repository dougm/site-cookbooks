#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
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

#include_recipe "java"

home = node[:hudson][:server][:home]
pkey = "#{home}/.ssh/id_rsa"

service "hudson" do
  action :nothing
end

node[:hudson][:server][:plugins].each do |name|
  remote_file "#{node[:hudson][:server][:home]}/plugins/#{name}.hpi" do
    source "#{node[:hudson][:mirror]}/latest/#{name}.hpi"
    owner node[:hudson][:server][:user]
    group node[:hudson][:server][:user]    
  end
end

case node.platform
when "ubuntu", "debian"
  # See http://hudson-ci.org/debian/

  node[:hudson][:server][:group] ||= "nogroup"

  package "daemon"
  # These are both dependencies of the hudson deb package
  package "jamvm"
  package "openjdk-6-jre"

  remote_file "/tmp/hudson.deb" do
    source "http://hudson-ci.org/latest/debian/hudson.deb"
  end


  remote_file "/tmp/hudson_ci_key" do
    source "http://hudson-ci.org/debian/hudson-ci.org.key"
  end

  execute "add-hudson-key" do
    command "apt-key add /tmp/hudson_ci_key"
    action :nothing
  end

  package "hudson" do
    provider Chef::Provider::Package::Dpkg
    source "/tmp/hudson.deb"
    action :install
  end

when "centos", "redhat"
  #see http://hudson-ci.org/redhat/

  node[:hudson][:server][:group] ||= node[:hudson][:server][:user]
   dst = "/tmp/hudson.rpm"

  execute "rpm-import-hudson-ci.org.key" do
    command "rpm --import http://hudson-ci.org/redhat/hudson-ci.org.key"
    action :nothing
  end

  execute "install-hudson" do
    command "rpm --force --install #{dst}"
    action :nothing
  end

  remote_file dst do
    source "#{node[:hudson][:mirror]}/latest/redhat/hudson.rpm"
    notifies :stop, resources(:service => "hudson"), :immediately
    notifies :run, resources(:execute => "rpm-import-hudson-ci.org.key"), :immediately
    notifies :run, resources(:execute => "install-hudson"), :immediately
    not_if { ::File.exists?(dst) }
  end
end

user node[:hudson][:server][:user] do
  action :modify
  home node[:hudson][:server][:home]
end

directory "#{node[:hudson][:server][:home]}/.ssh" do
  action :create
  mode 0700
  owner node[:hudson][:server][:user]
  group node[:hudson][:server][:group]
end

execute "ssh-keygen -f #{pkey} -N ''" do
  user  node[:hudson][:server][:user]
  group node[:hudson][:server][:group]
  not_if { File.exists?(pkey) }
end

ruby_block "store hudson ssh pubkey" do
  block do
    node.set[:hudson][:server][:pubkey] = File.open("#{pkey}.pub") { |f| f.gets }
  end
end

pid_file = "/var/run/hudson.pid"
#restart if this run only added new plugins
service "hudson" do
  only_if do
    if File.exists?(pid_file)
      htime = File.mtime(pid_file)
      Dir["#{node[:hudson][:server][:home]}/plugins/*.hpi"].select { |file|
        File.mtime(file) > htime
      }.size > 0
    end
  end
  action :stop
end

service "hudson" do
  action :start
  only_if { true }
end
