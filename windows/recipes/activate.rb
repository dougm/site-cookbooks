#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: activate
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

#"Activate Windows Online"

require 'ruby-wmi'

#http://technet.microsoft.com/en-us/library/bb457096.aspx
#XXX requires different sauce for Windows 7
wpa = WMI::Win32_WindowsProductActivation.find(:first)
if wpa.ActivationRequired == 1
  Chef::Log.info("Activating with product key=#{wpa.ProductID}")
  rc = wpa.ActivateOnline
  if rc == 0
    Chef::Log.info("#{wpa.ServerName} activated")
  else
    Chef::Application.fatal!("Failed to activate #{wpa.ServerName} (WMI error=#{rc})")
  end
else
    Chef::Log.debug("#{wpa.ServerName} has already been activated")
end
