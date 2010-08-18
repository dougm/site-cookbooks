#
# Cookbook Name:: perforce
# Attributes:: perforce
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

set_unless[:perforce][:mirror]  = "http://www.perforce.com/downloads/perforce"
set_unless[:perforce][:version] = "r09.2"

if node[:os] == "windows"
  set_unless[:perforce][:bindir] = "C:/WINDOWS/System32"
else
  set_unless[:perforce][:bindir] = "/usr/bin"
end
