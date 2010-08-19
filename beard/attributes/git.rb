#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: beard
# Attributes:: git
#
# Copyright 2010, VMware, Inc
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

#slightly old default for a better chance to work on old systems
set[:git][:version] = "1.6.3"
set[:git][:mirror]  = "http://www.kernel.org/pub/software/scm/git"
set[:git][:prefix] = "/usr"
set[:git][:make] = "make NO_EXPAT=1 NO_NSEC=1"
