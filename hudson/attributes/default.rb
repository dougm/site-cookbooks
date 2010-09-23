#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Attributes:: default
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

default[:hudson][:mirror] = "http://hudson-ci.org"
default[:hudson][:java_home] = ENV['JAVA_HOME']

default[:hudson][:server][:home] = "/var/lib/hudson"
default[:hudson][:server][:user] = "hudson"
default[:hudson][:server][:port] = 8080
default[:hudson][:server][:host] = node[:fqdn]
default[:hudson][:server][:url]  = "http://#{node[:hudson][:server][:host]}:#{node[:hudson][:server][:port]}"

#download the latest version of plugins, bypassing update center
#example: ["git", "URLSCM", ...]
default[:hudson][:server][:plugins] = []

#See Hudson >> Nodes >> $name >> Configure

#"Name"
default[:hudson][:node][:name] = node[:fqdn]

#"Description"
default[:hudson][:node][:description] =
  "#{node[:platform]} #{node[:platform_version]} " <<
  "[#{node[:kernel][:os]} #{node[:kernel][:release]} #{node[:kernel][:machine]}] " <<
  "slave on #{node[:hostname]}"

#"# of executors"
default[:hudson][:node][:executors] = 1

#"Remote FS root"
if node[:os] == "windows"
  default[:hudson][:node][:home] = "C:/hudson"
elsif node[:os] == "darwin"
  default[:hudson][:node][:home] = "/Users/hudson"
else
  default[:hudson][:node][:home] = "/home/hudson"
end

#"Labels"
default[:hudson][:node][:labels] = (node[:tags] || []).join(" ")

#"Usage"
#  "Utilize this slave as much as possible" -> "normal"
#  "Leave this machine for tied jobs only"  -> "exclusive"
default[:hudson][:node][:mode] = "normal"

#"Launch method"
#  "Launch slave agents via JNLP"                        -> "jnlp"
#  "Launch slave via execution of command on the Master" -> "command"
#  "Launch slave agents on Unix machines via SSH"         -> "ssh"
if node[:os] == "windows"
  default[:hudson][:node][:launcher] = "jnlp"
else
  default[:hudson][:node][:launcher] = "ssh"
end

#"Availability"
#  "Keep this slave on-line as much as possible"                   -> "always"
#  "Take this slave on-line when in demand and off-line when idle" -> "demand"
default[:hudson][:node][:availability] = "always"

#  "In demand delay"
default[:hudson][:node][:in_demand_delay] = 0
#  "Idle delay"
default[:hudson][:node][:idle_delay] = 1

#"Node Properties"
#[x] "Environment Variables"
default[:hudson][:node][:env] = nil

default[:hudson][:node][:user] = "hudson"

#SSH options
default[:hudson][:node][:ssh_host] = node[:fqdn]
default[:hudson][:node][:ssh_port] = 22
default[:hudson][:node][:ssh_user] = default[:hudson][:node][:user]
default[:hudson][:node][:ssh_pass] = nil
default[:hudson][:node][:jvm_options] = nil
#hudson master defaults to: "#{ENV['HOME']}/.ssh/id_rsa"
default[:hudson][:node][:ssh_private_key] = nil
