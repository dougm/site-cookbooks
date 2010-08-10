#
# Cookbook Name:: windows
# Attributes:: xemacs
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

#21.4.22 breaks jde
default[:xemacs][:release] = "21.4.21"
#mirror list at: http://xemacs.org/Download/win32/#InnoSetup-Download
default[:xemacs][:mirror] = "http://ftp.xemacs.org/pub/xemacs"
default[:xemacs][:dir] = "C:\\XEmacs"
default[:xemacs][:type] = "complete" #recommended, complete, minimal or custom
