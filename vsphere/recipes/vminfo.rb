#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: vsphere
# Recipe:: vminfo
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

def obj_to_hash(obj, keys)
  hash = Mash.new
  keys.each do |m|
    val = obj.send(m)
    hash[m] = val if val
  end
  hash
end

def vm_info(vm)
  vm_config = vm.config
  vminfo = Mash.new
  vminfo[:name] = vm.name

  vminfo[:config] = Mash.new

  [:alternateGuestName, :annotation, :changeTrackingEnabled, :changeVersion,
   :cpuHotAddEnabled, :cpuHotRemoveEnabled, :guestFullName, :guestId,
   :hotPlugMemoryIncrementSize, :hotPlugMemoryLimit, :instanceUuid, :locationId,
   :memoryHotAddEnabled, :name, :template, :uuid, :version].each do |m|
    val = vm_config.send(m)
    vminfo[:config][m] = val if val and not (val.class == String and val.empty?)
  end

  vminfo[:config][:datastoreUrl] =
    Hash[*vm_config.datastoreUrl.collect {|ds| [:url, ds.url, :name, ds.name]}.flatten]

  vminfo[:config][:files] =
    obj_to_hash(vm_config.files,
                [:logDirectory, :snapshotDirectory, :suspendDirectory, :vmPathName])

  vminfo[:config][:memoryAllocation] =
    obj_to_hash(vm_config.memoryAllocation,
                [:expandableReservation, :limit, :overheadLimit, :reservation])

  vminfo[:config][:hardware] =
    obj_to_hash(vm_config.hardware,
                [:memoryMB, :numCPU])

  vminfo[:config][:tools] =
    obj_to_hash(vm_config.tools,
                [:syncTimeWithHost, :toolsUpgradePolicy, :toolsVersion])

  #.vmx and guestinfo props
  vminfo[:config][:extra] = Mash.new
  vm_config.extraConfig.each do |opt|
    vminfo[:config][:extra][opt.key] = opt.value unless opt.value.empty?
  end

  vminfo[:layout] = obj_to_hash(vm.layout, [:configFile, :logFile, :swapFile])
  vminfo[:layout][:disk] = vm.layout.disk.collect { |d| obj_to_hash(d, [:key, :diskFile]) }

  vminfo[:network] = vm.network.collect { |n| obj_to_hash(n, [:name]) }

  vminfo[:resourcePool] = obj_to_hash(vm.resourcePool, [:name])

  vminfo[:runtime] = obj_to_hash(vm.runtime, [:bootTime])
  vminfo[:runtime][:host] = obj_to_hash(vm.runtime.host, [:name])
  vminfo[:runtime][:host][:product] =
    obj_to_hash(vm.runtime.host.summary.config.product,
                [:apiType, :apiVersion, :build, :fullName, :name, :osType, :vendor, :version])

  vminfo[:summary] = Mash.new
  vminfo[:summary][:quickStats] =
    obj_to_hash(vm.summary.quickStats,
                [:balloonedMemory, :compressedMemory, :consumedOverheadMemory, :guestMemoryUsage,
                 :hostMemoryUsage, :privateMemory, :sharedMemory, :swappedMemory])

  vminfo
end

if node.vsphere.connection.host
  vm = vsphere_find_vm
  if vm
    vminfo = vm_info(vm)
    node.automatic_attrs[:vsphere] = Mash.new
    node.automatic_attrs[:vsphere][:vm] = vminfo
  end
end
