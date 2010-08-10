#
# Cookbook Name:: windows
# File:: spork
# Author:: Doug MacEachern <dougm@vmware.com>
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

require 'fileutils'
require 'rubygems'
require 'mixlib/cli'
$:.unshift(File.join(File.dirname(Gem.bin_path('chef', 'chef-solo')), "..", "lib"))
require 'chef/util/windows/net_use'

class Spork
  include Mixlib::CLI

  option :machine,
    :short => "-m hostname",
    :long  => "--machine hostname",
    :description => "Hostname or IP for remote computer",
    :XXX_required => true

  option :username,
    :short => "-u username",
    :long  => "--username username",
    :description => "Username for remote computer"

  option :password,
    :short => "-p password",
    :long  => "--password password",
    :description => "Password for username"

  option :workdir,
    :short => "-w directory",
    :long => "--workdir directory",
    :default => "\\chef",
    :description => "Set the working directory of the process (relative to remote C:\ drive)."

  option :proxy,
    :short => "-P hostname:port",
    :long  => "--proxy hostname:port",
    :description => "HTTP proxy hostname:port (used within remote computer)"

  option :ruby,
    :short => "-R path",
    :long => "--ruby path",
    :default => "C:\\Ruby",
    :description => "Ruby installation path"

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :boolean      => true,
    :show_options => true,
    :exit         => 0

  def parse_options
    args = super
    #XXX :required bug in mixlib/cli?
    unless config.has_key?(:machine)
      puts "You must supply -m!"
      puts @opt_parser
      exit 2
    end
    @add_mount = config.has_key?(:username) && !is_mounted
    @rel_workdir = config[:workdir].sub(/^\\/, '')
    args
  end

  def workdir
    @rel_workdir
  end

  def fjoin(*args)
    args.join("\\")
  end

  def ruby_bin(file)
    ['ruby', fjoin(config[:ruby], "bin", file)]
  end

  def unc_path
    "\\\\#{config[:machine]}"
  end

  def admin_share
    fjoin(unc_path, 'c$')
  end

  def is_mounted
    @net_use ||= Chef::Util::Windows::NetUse.new(admin_share)
    begin
      @net_use.device
      return true
    rescue
      return false
    end
  end

  def mount_admin_share
    if @add_mount && !is_mounted
      cmd = ['net', 'use', admin_share, "/user:#{config[:username]}", config[:password]]
      run_command(cmd) #@net_use.add(admin_share) #XXX add user/pass options
      begin
        device = @net_use.device
        puts "Mounted #{admin_share} for file operations"
      rescue
        raise "Failed to mount #{admin_share}"
      end
    end
  end

  def unmount_admin_share
    if @add_mount && is_mounted
      puts "Unmounting #{admin_share}"
      @net_use.delete
    end
  end

  def run_command(cmd)
    cmd = cmd.join(' ')
    puts "command: #{cmd}"
    system(cmd)
  end

  def cmd_mkdir(dirs)
    dirs.each do |dir|
      dir = fjoin(admin_share, workdir, dir) unless dir =~ /\\/
      if File.exists?(dir)
        puts "#{dir} directory already exists"
      else
        FileUtils.mkdir_p(dir, {:verbose => true})
      end
    end
  end

  def cmd_cp(files)
    path = fjoin(admin_share, workdir)

    cmd_mkdir([path])

    files.each do |file|
      if File.directory?(file)
        FileUtils.cp_r(file, path, {:verbose, true})
      else
        FileUtils.cp(file, fjoin(path, File.basename(file)), {:verbose, true})
      end
    end
  end

  def cmd_exec(args)
    cmd = ['psexec', unc_path]
    #passthru psexec options
    [:username, :password, :workdir].each do |opt_name|
      if config.has_key?(opt_name)
        cmd << [options[opt_name][:short].split.first, config[opt_name]]
      end
    end
    run_command(cmd << args)
  end

  def cmd_gem_install(args)
    local_gems = []
    cmd = ruby_bin('gem') << 'install'
    if config.has_key?(:proxy)
      cmd << "--http-proxy=#{config[:proxy]}"
    end

    args.each do |arg|
      if arg =~ /\.gem$/
        local_gems << arg
        cmd << File.basename(arg)
      else
        cmd << arg
      end
    end
    cmd_cp(local_gems) if local_gems.size != 0
    cmd_exec(cmd)
  end

  def cmd_devgem(args)
    cmd_gem_install(args.clone << ["--ignore-dependencies", "--no-ri", "--no-rdoc"])
  end

  CSCRIPT = ['cmd.exe', '/c', 'cscript', '/nologo']

  def cmd_setup(args)
    vbscript = "chef-client-setup.vbs"
    cmd_cp(fjoin(File.dirname(__FILE__), vbscript))

    cmd = CSCRIPT.clone << vbscript
    if config.has_key?(:proxy)
      cmd << config[:proxy]
    end

    cmd_exec(cmd)
  end

  def cmd_solo(args)
    cmd = ruby_bin('chef-solo')
    {'-c', 'solo.rb', '-j', 'node.rb'}.each do |opt,val|
      if File.exists?(fjoin(admin_share, workdir, val))
        cmd << opt << val
      end
    end
    cmd_exec(cmd << args)
  end

  def cmd_client(args)
    cmd = ruby_bin('chef-client')
    cmd_exec(cmd << args)
  end

  def run
    args = parse_options
    if args.size == 0
      puts "No command specified"
      exit 1
    end

    if self.respond_to?("cmd_#{args[0]}")
      mount_admin_share
      self.send("cmd_#{args.shift}", args)
      unmount_admin_share
    else
      cmd_exec(args)
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  Spork.new.run
end
