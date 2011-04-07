#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: vsphere
# Library:: vsphere_util
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

def vsphere_connect
  begin
    require 'rbvmomi'
  rescue LoadError
    Chef::Log.info("vsphere_connect: gem rbvmomi not installed")
    return nil
  end

  opts = {}
  node.vsphere.connection.to_hash.each do |k,v|
    opts[k.to_sym] = v
  end
  Chef::Log.debug("vsphere_connect: #{opts[:host]}")

  begin
    return RbVmomi.connect opts
  rescue => e
    puts Chef::Log.error("vsphere: #{e}")
  end
end

def vm_uuid
  if node[:dmi] and node[:dmi][:system]
    return node[:dmi][:system][:uuid].downcase
  end
end

def vsphere_find_vm
  vim = vsphere_connect
  return nil unless vim

  vmFolder = vim.serviceInstance.find_datacenter.vmFolder
  uuid = vm_uuid
  if uuid
    vm = vmFolder.findByUuid(uuid)
    if vm
      Chef::Log::debug("vsphere vm found by uuid")
      return vm
    else
      Chef::Log::debug("vsphere vm not found by uuid=#{uuid}")
    end
  end

  [:fqdn, :hostname].each do |name|
    vm = vmFolder.findByDnsName(node[name])
    if vm
      Chef::Log::debug("vsphere vm found by #{name}")
      return vm
    else
      Chef::Log::debug("vsphere vm not found by #{name}=#{node[name]}")
    end
  end

  vm = vmFolder.findByIp(node.ipaddress)
  if vm
    Chef::Log::debug("vsphere vm found by ipaddress")
    return vm
  else
    Chef::Log::debug("vsphere vm not found by ipaddress=#{node.ipaddress}")
  end
end
