#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hudson
# Provider:: cli
#
# Copyright:: 2010, VMware, Inc.
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

def action_run
  url = @new_resource.url || node[:hudson][:server][:url]
  home = @new_resource.home || node[:hudson][:node][:home]

  #recipes will chown to hudson later if this doesn't already exist
  directory "home for hudson-cli.jar" do
    action :create
    path node[:hudson][:node][:home]
  end

  cli_jar = ::File.join(home, "hudson-cli.jar")
  remote_file cli_jar do
    source "#{url}/jnlpJars/hudson-cli.jar"
    not_if { ::File.exists?(cli_jar) }
  end

  java_home = node[:hudson][:java_home] || (node.has_key?(:java) ? node[:java][:jdk_dir] : nil)
  if java_home == nil
    java = "java"
  else
    java = ::File.join(java_home, "bin", "java")
  end

  command = "#{java} -jar #{cli_jar} -s #{url} #{@new_resource.command}"

  hudson_execute command do
    cwd home
    block { |stdout| new_resource.block.call(stdout) } if new_resource.block
    only_if new_resource.only_if
  end
end
