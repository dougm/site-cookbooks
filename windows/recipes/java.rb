#
# Author:: Doug MacEachern <dougm@vmware.com>
# Cookbook Name:: windows
# Recipe:: java
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

#XXX no direct public download link for sun java
#Hudson "Performs a license click through and obtains the one-time URL for downloading bits."
#if anyone feels up for converting to ruby:
#http://github.com/kohsuke/hudson/blob/master/core/src/main/java/hudson/tools/JDKInstaller.java
#in the meantime, just plop the .exe's behind any http server and configure java[:mirror]

#jdk-6u20-windows-x64.exe
#jdk-6u20-windows-i586.exe
installer = ["jdk", node[:java][:release], "windows", node[:java][:jdk_arch]].join("-") + ".exe"

java_home = node[:java][:jdk_dir]
jre_home = node[:java][:jre_dir]

dst = "#{java_home}\\#{installer}"

directory java_home do
  action :create
end

remote_file dst do
  source "#{node[:java][:mirror]}/jdk/packages/windows/#{installer}"
  checksum node[:java][:checksum][installer]
  not_if { File.exists?(dst) }
end

execute "install #{installer}" do
  command "#{dst} /s /v/qn REBOOT=Suppress INSTALLDIR=#{java_home} /INSTALLDIRPUBJRE=#{jre_home}"
  not_if { File.exists?("#{java_home}/bin/javac.exe") }
end

env "JAVA_HOME" do
  action :create
  value java_home
end

env "PATH" do
  action :modify
  delim File::PATH_SEPARATOR
  value "%JAVA_HOME%\\bin"
end
