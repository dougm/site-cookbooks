#
# Cookbook Name:: swaps
# Library:: linux
# Author:: Doug MacEachern <dougm@vmware.com>
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

def proc_swaps
  swaps = []
  io = File.open("/proc/swaps")
  entries = io.readlines
  fields = entries.shift.split.map { |f| f.downcase.strip.to_sym }
  entries.each do |line|
    entry = {}
    row = line.split
    fields.each_with_index do |key, i|
      entry[key] = row[i]
    end
    swaps << entry
  end
  io.close
  swaps
end

def set_proc_swaps_attributes(reload=false)
  if reload
    o = Ohai::System.new
    o.require_plugin("linux::memory")
    node.automatic_attrs.merge! o.data
  end

  node.automatic_attrs[:memory][:swaps] = proc_swaps
end
