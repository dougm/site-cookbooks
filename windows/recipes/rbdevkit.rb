#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: rbdevkit
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

require 'yaml'

exe = "DevKit-tdm-32-#{node[:rbdevkit][:release]}-sfx.exe"
dst = "#{node[:rbdevkit][:dir]}\\rubydevkit.exe"
yml = "#{node[:rbdevkit][:dir]}\\config.yml"

directory node[:rbdevkit][:dir] do
  action :create
end

remote_file dst do
  source "#{node[:rbdevkit][:mirror]}/#{exe}"
  backup false
  notifies :run, "execute[rbdevkit-extract]", :immediately
  notifies :run, "execute[rbdevkit-init]", :immediately
  notifies :create, "ruby_block[rbdevkit-rubies]", :immediately
  notifies :run, "execute[rbdevkit-install]", :immediately
  notifies :delete, "file[#{dst}]", :immediately
  not_if { File.exists?(yml) }
end

execute "rbdevkit-extract" do
  command "#{dst} -y"
  cwd node[:rbdevkit][:dir]
  action :nothing
end

execute "rbdevkit-init" do
  command "ruby #{node[:rbdevkit][:dir]}\\dk.rb init"
  cwd node[:rbdevkit][:dir]
  action :nothing
end

#dk.rb doesn't find my ruby
ruby_block "rbdevkit-rubies" do
  block do
    stdruby = "C:\\ruby"
    rubies = YAML.load_file(yml)
    unless rubies.is_a?(Array) && !rubies.empty? && File.directory?(stdruby)
      Chef::Log.info("dk.rb did not find any rubies, but I did.. re-generating #{yml}")
      rubies = [stdruby]
      File.open(yml, 'w') { |f| f.write(rubies.to_yaml) }
    end
  end
  action :nothing
end

execute "rbdevkit-install" do
  command "ruby #{node[:rbdevkit][:dir]}\\dk.rb install"
  cwd node[:rbdevkit][:dir]
  action :nothing
end

file dst do
  action :nothing
end
