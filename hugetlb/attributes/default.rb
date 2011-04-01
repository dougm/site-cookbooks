#
# Cookbook Name:: hugetlb
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

def file_readline(file)
  File.open(file).readlines.first.strip
end

def cmd_readline(cmd)
  IO.popen(cmd).readlines.first.strip
end

if node[:os] == "linux"
  default[:hugetlb] = Mash.new
  default[:hugetlb][:kernel][:shmmax] = file_readline("/proc/sys/kernel/shmmax")

  Dir["/proc/sys/vm/*huge{pages,tlb}*"].each do |file|
    default[:hugetlb][:vm][File.basename(file)] = file_readline(file)
  end

  [:hard, :soft].each do |limit|
    default[:hugetlb][:limit_memlock][limit] =
      cmd_readline("sh -c 'ulimit -#{limit.to_s.chars.first.upcase} -l'")
  end

  #XXX >> ohai/plugins/linux/memory.rb
  File.open("/proc/meminfo").readlines.each do |line|
    next unless line =~ /^(Anon)?Huge/
    key, val = line.split(/:\s+/)
    node.automatic_attrs[:memory][key.downcase] = val.gsub(/\s+/, "")
  end

  Dir["/sys/kernel/mm/hugepages/*"].each do |subdir|
    size = File.basename(subdir)
    Dir["#{subdir}/*"].each do |file|
      default[:hugetlb][:mm][size][File.basename(file)] = file_readline(file)
    end
  end

  #2.6.38+ kernels only
  Dir["/sys/kernel/mm/transparent_hugepage/*"].each do |file|
    key = File.basename(file)
    if File.directory?(file)
      Dir["#{file}/*"].each do |name|
        default[:hugetlb][:mm][:transparent_hugepage][key][File.basename(name)] = file_readline(name)
      end
    else
      default[:hugetlb][:mm][:transparent_hugepage][key] = file_readline(file)
    end
  end

  File.open("/boot/config-#{node.kernel.release}").readlines.each do |line|
    next unless line =~ /^CONFIG_(HUGETLB|TRANSPARENT_HUGEPAGE)/
    key, val = line.strip.split("=")
    default[:hugetlb][:boot][key.downcase] = (val == "y")
  end
end
