#
# Cookbook Name:: windows
# Attributes:: java
#
# Copyright 2010, VMware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default[:java][:release] = "6u21"
if node[:kernel][:machine] == "x86_64"
  default[:java][:jdk_arch] = "x64"
else
  default[:java][:jdk_arch] = "i586"
end
default[:java][:jdk_dir] = "C:\\jdk"
default[:java][:jre_dir] = "C:\\jre"

set[:java][:checksum]["jdk-6u20-windows-x64.exe"] = "ef317ae81689c1f33994b81bf8c98beb3996d572"
set[:java][:checksum]["jdk-6u20-windows-i586.exe"] = "ca690354bda417579961d404ff62eee6baf4c3ab"

set[:java][:checksum]["jdk-6u21-windows-x64.exe"] = "88921064b0a88f52fa9e6f7629ad386169853e3d"
set[:java][:checksum]["jdk-6u21-windows-i586.exe"] = "b8644c3e987ec30bf02a63c9d88c44f69062e316"
