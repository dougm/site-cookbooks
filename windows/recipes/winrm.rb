#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: winrm
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

#XXX installer for < 2008 || 7
#XXX quickconfig?

ruby_block "winrm config" do
  block do
    config = node.winrm.to_hash['config']
    if config != winrm_attributes_get['config']
      winrm_attributes_set config
      Chef::Log.debug("winrm config updated")
    else
      Chef::Log.debug("winrm config unchanged")
    end
  end
end
