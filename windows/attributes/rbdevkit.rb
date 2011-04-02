#
# Cookbook Name:: windows
# Attributes:: rbdevkit
#
# Copyright 2011, VMware, Inc.
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

default[:rbdevkit][:release] = "4.5.1-20101214-1400"
default[:rbdevkit][:mirror] = "http://cloud.github.com/downloads/oneclick/rubyinstaller"
default[:rbdevkit][:dir] = "C:\\DevKit"
