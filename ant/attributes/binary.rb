#
# Cookbook Name:: ant
# Attributes:: binary
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

default[:ant][:mirror] = "http://archive.apache.org/dist/ant/binaries"
default[:ant][:release] = "1.7.1"
default[:ant][:junit_jar] = "http://github.com/downloads/KentBeck/junit/junit-4.8.2.jar"
default[:ant][:dir] = "/usr/share/java"
default[:ant][:link] = true

