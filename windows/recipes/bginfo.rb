#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: bginfo
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

#http://technet.microsoft.com/en-us/sysinternals/bb897557.aspx

node[:bginfo][:shortcuts].each do |dir|
  windows_shortcut "#{dir}\\#{node[:bginfo][:shortcut_name]}.lnk" do
    target "#{node[:sysinternals][:dir]}\\bin\\bginfo.exe"
    arguments "/timer:0"
    description "created by Chef"
    action :create
  end
end

