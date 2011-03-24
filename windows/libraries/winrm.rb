#
# Cookbook Name:: windows
# Library:: winrm
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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32ole'
end
require 'rexml/document'

def uncapitalize(s)
  s.sub(/^\w/) { $&.downcase }
end

def winrm_populate_hash(hash, element)
  if element.has_elements?
    hash = hash[uncapitalize element.name] = {}
    element.elements.each do |row|
      winrm_populate_hash(hash, row)
    end
  else
    hash[uncapitalize element.name] = element.texts.first.to_s
  end
end

def winrm_to_hash(xml)
  doc = REXML::Document.new(xml)
  hash = {}
  winrm_populate_hash(hash, doc.root)
  hash
end

def winrm_add_elements(element, hash)
  hash.each do |k,v|
    child = element.add_element REXML::Element.new("cfg:#{uncapitalize k}")

    if v.is_a? Hash
      winrm_add_elements(child, v)
    else
      child.text = v.to_s
    end
  end
end

def winrm_to_xml(hash)
  doc = REXML::Document.new
  winrm_add_elements(doc, hash)
  doc.root.add_namespace('cfg', "http://schemas.microsoft.com/wbem/wsman/1/config")
  doc.root.add_attribute('xml:lang', "en-US")
  doc.to_s
end

def winrm_attributes_get
  begin
    wsman = WIN32OLE.new("WSMAN.Automation")
    session = wsman.CreateSession
    locator = wsman.CreateResourceLocator("winrm/config")
    xml = session.Get(locator)
    winrm_to_hash(xml)
  rescue
    nil #winrm components are not installed
  end
end

def winrm_attributes_set(hash)
  wsman = WIN32OLE.new("WSMAN.Automation")
  session = wsman.CreateSession
  unless hash['config']
    hash = { 'config' => hash }
  end
  xml = winrm_to_xml(hash)
  session.Put("winrm/config", xml)
end
