#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: swaps
# Recipe:: linux
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

if node[:swaps][:total] #how much you want?
  total = node[:swaps][:total]
  memsize = node.memory.total.to_i / 1024
  swapsize = node.memory.swap.total.to_i / 1024
  if total =~ /%$/
    total = ((memsize * total.to_i) / 100)
  end
  delta = total.to_i - swapsize
  delta = 0 if delta == 1 #cut some slack
else
  delta = 0
end

if delta != 0
  Chef::Log.debug("[swaps] adjusting with delta=#{delta}")

  if filename = node[:swaps][:filename]
    entry = node.memory.swaps.select {|e| e[:filename] == filename }.first

    if entry
      shrink = (entry[:size].to_i / 1024)
      delta += shrink
      execute "swapoff #{filename}"
      file filename do
        action :delete
        backup false
      end
      Chef::Log.debug("[swaps] swapoff #{filename} makes delta=#{delta}")
    end

    if delta < 0
      if entry
        msg = "[swaps] shrunk by #{shrink} after swapoff #{filename}, cannot shrink any further"
      else
        msg = "[swaps] #{filename} was not swap enabled, unable to shrink at all"
      end
      Chef::Log.warn(msg)
    else
      execute "dd if=/dev/zero of=#{filename} bs=1M count=#{delta}" do
        not_if do
          File.exists?(filename) and (File.size(filename) / (1024*1024)) == delta
        end
      end

      execute "mkswap #{filename}" do
        not_if do
          IO.popen("file -b #{filename}").readlines.first =~ /swap file/
        end
      end

      execute "swapon #{filename}"
    end

    ruby_block "reload proc_swaps attributes" do
      block do
        set_proc_swaps_attributes(true)
      end
    end
  else
    #XXX option to mkswap an a new disk or partition
    Chef::Log.warn("[swaps] node.swaps.filename not defined, nothing todo")
  end
else
  Chef::Log.debug("[swaps] no changes needed (delta=#{delta}).")
end
