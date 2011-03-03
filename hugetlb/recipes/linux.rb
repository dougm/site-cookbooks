#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: hugetlb
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

sysctl = []
[:vm, :kernel].each do |sys|
  node.hugetlb[sys].each do |prop,val|
    if val =~ /%$/
      case prop
      when "nr_hugepages"
        val = ((node.memory.total.to_i * val.to_i) / 100) / node.memory.hugepagesize.to_i
      when "shmmax"
        val = ((node.memory.total.to_i * val.to_i) / 100) * 1024
      end
    elsif !val.to_s.match(/^\d+$/)
      case prop
      when "hugetlb_shm_group"
        val = Etc.getgrnam(val).gid
      end
    end

    sysctl << "#{sys}.#{prop} = #{val}"

    #apply settings now
    file "/proc/sys/#{sys}/#{prop}" do
      content "#{val.to_i}\n"
      backup false
    end
  end
end

#persist settings on reboot

directory "/etc/sysctl.d" do
  mode "0755"
end

file "/etc/sysctl.d/60-hugetlb_sysctl.conf" do
  mode "0644"
  content sysctl.join("\n") + "\n"
end

directory "/etc/security/limits.d" do
  mode "0755"
end

group = node.hugetlb.vm.hugetlb_shm_group
if group.to_s.match(/^\d+$/)
  group = Etc.getgrgid(group.to_i).name
end

limits = {}
[:soft, :hard].each do |lim|
  val = node.hugetlb.limit_memlock[lim]
  if val =~ /%$/
    limits[lim] = ((node.memory.total.to_i * val.to_i) / 100)
  else
    limits[lim] = node.hugetlb.limit_memlock[lim]
  end
end
 
template "/etc/security/limits.d/hugetlb_memlock.conf" do
  mode "0644"
  source "limits.conf.erb"
  variables(:hugetlb_shm_group    => group,
            :hugetlb_soft_memlock => limits[:soft],
            :hugetlb_hard_memlock => limits[:hard])
end

