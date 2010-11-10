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

pkey = "#{node[:hudson][:server][:home]}/.ssh/id_rsa"
tmp = "/tmp"

user node[:hudson][:server][:user] do
  home node[:hudson][:server][:home]
end

directory node[:hudson][:server][:home] do
  recursive true
  owner node[:hudson][:server][:user]
  group node[:hudson][:server][:group]
end

directory "#{node[:hudson][:server][:home]}/.ssh" do
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

directory "#{node[:hudson][:server][:home]}/plugins" do
  owner node[:hudson][:server][:user]
  group node[:hudson][:server][:group]
  only_if { node[:hudson][:server][:plugins].size > 0 }
end

node[:hudson][:server][:plugins].each do |name|
  remote_file "#{node[:hudson][:server][:home]}/plugins/#{name}.hpi" do
    source "#{node[:hudson][:mirror]}/latest/#{name}.hpi"
    backup false
    owner node[:hudson][:server][:user]
    group node[:hudson][:server][:group]
  end
end

case node.platform
when "ubuntu", "debian"
  # See http://hudson-ci.org/debian/

  remote = "#{node[:hudson][:mirror]}/latest/debian/hudson.deb"
  package_provider = Chef::Provider::Package::Dpkg
  pid_file = "/var/run/hudson/hudson.pid"
  install_starts_service = true

  package "daemon"
  # These are both dependencies of the hudson deb package
  package "jamvm"
  package "openjdk-6-jre"

  if node.platform == "debian"
    package "psmisc"
  end

  remote_file "#{tmp}/hudson-ci.org.key" do
    source "#{node[:hudson][:mirror]}/debian/hudson-ci.org.key"
  end

  execute "add-hudson-key" do
    command "apt-key add #{tmp}/hudson-ci.org.key"
    action :nothing
  end

when "centos", "redhat"
  #see http://hudson-ci.org/redhat/

  remote = "#{node[:hudson][:mirror]}/latest/redhat/hudson.rpm"
  package_provider = Chef::Provider::Package::Rpm
  pid_file = "/var/run/hudson.pid"
  install_starts_service = false

  execute "add-hudson-key" do
    command "rpm --import #{node[:hudson][:mirror]}/redhat/hudson-ci.org.key"
    action :nothing
  end

end

#"hudson stop" may (likely) exit before the process is actually dead
#so we sleep until nothing is listening on hudson.server.port (according to netstat)
ruby_block "netstat" do
  block do
    10.times do
      if IO.popen("netstat -lnt").entries.select { |entry|
          entry.split[3] =~ /:#{node[:hudson][:server][:port]}$/
        }.size == 0
        break
      end
      Chef::Log.debug("service[hudson] still listening (port #{node[:hudson][:server][:port]})")
      sleep 1
    end
  end
  action :nothing
end

service "hudson" do
  supports [ :stop, :start, :restart, :status ]
  #"hudson status" will exit(0) even when the process is not running
  status_command "test -f #{pid_file} && kill -0 `cat #{pid_file}`"
  action :nothing
end

local = File.join(tmp, File.basename(remote))

remote_file local do
  source remote
  backup false
  notifies :stop, "service[hudson]", :immediately
  notifies :create, "ruby_block[netstat]", :immediately #wait a moment for the port to be released
  notifies :run, "execute[add-hudson-key]", :immediately
  notifies :install, "package[hudson]", :immediately
  unless install_starts_service
    notifies :start, "service[hudson]", :immediately
  end
  if node[:hudson][:server][:use_head] #XXX remove when CHEF-1848 is merged
    action :nothing
  end
end

http_request "HEAD #{remote}" do
  only_if { node[:hudson][:server][:use_head] } #XXX remove when CHEF-1848 is merged
  message ""
  url remote
  action :head
  if File.exists?(local)
    headers "If-Modified-Since" => File.mtime(local).httpdate
  end
  notifies :create, "remote_file[#{local}]", :immediately
end

#this is defined after http_request/remote_file because the package
#providers will throw an exception if `source' doesn't exist
package "hudson" do
  provider package_provider
  source local
  action :nothing
end

#restart if this run only added new plugins
log "plugins updated, restarting hudson" do
  #ugh :restart does not work, need to sleep after stop.
  notifies :stop, "service[hudson]", :immediately
  notifies :create, "ruby_block[netstat]", :immediately
  notifies :start, "service[hudson]", :immediately
  only_if do
    if File.exists?(pid_file)
      htime = File.mtime(pid_file)
      Dir["#{node[:hudson][:server][:home]}/plugins/*.hpi"].select { |file|
        File.mtime(file) > htime
      }.size > 0
    end
  end
end

