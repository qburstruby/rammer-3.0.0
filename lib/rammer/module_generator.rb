=begin
**************************************************************************
* The MIT License (MIT)

* Copyright (c) 2013-2014 QBurst Technologies Inc.

* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.

**************************************************************************
=end

require "rammer/version"
require 'fileutils'
require_relative 'reserved_words'

$gem_file_name = "rammer-"+Rammer::VERSION

module Rammer
=begin
Generator class for mounting the rammer modules. It mounts the module, creates required files and configurations , 
and the runs bundle install.
=end
  class ModuleGenerator
    attr_accessor :target_dir, :project_name, :module_class, :module_name, :gem_path, :action
    
=begin
Initiliazes the following attributes : 
    project_name (application name), module_class (class name for the application), target_dir (new application path),
    module_name (rammer module name), action (viber action to plugin or unplug) and gem_path (path at which the gem is installed)
=end
    def initialize(options)
      @project_name = options[:project_name]
      @module_class = options[:module_class]
      @module_name = options[:module_name]
      @action = options[:action]
      @target_dir = Dir.pwd
      path = `gem which rammer`
      @gem_path = path.split($gem_file_name,2).first + "/" + $gem_file_name
    end
    
=begin
Creates the required files and configuration setup while module plugin or unplug.
=end
    def run
      case @action
      when "-p","-plugin"
        flag = require_module_to_base
        mount_module unless flag
        copy_module
        create_migrations_and_models
        add_gems
        oauth_message if @module_name == "oauth" && !flag
      when "-u","-unplug"
        unmount_module
      end
    end
    
=begin
Mounts the module onto the application.
=end
    def mount_module
      file = File.open("#{@target_dir}/app/apis/#{@project_name}/base.rb", "r+")
      file.each do |line|
        while line == "\tclass Base < Grape::API\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("\t\tmount ") 
          file.puts(@module_class)
          file.write(rest)
          break
        end
      end
      $stdout.puts "\e[1;35m\tmounted\e[0m\t#{@module_class}"
    end
    
=begin
Checks whether the module is already mounted and if not then configures for mounting.
=end
    def require_module_to_base
      file = File.open("#{@target_dir}/app/apis/#{@project_name}/base.rb", "r+")
      file.each do |line|
        while line == "require_relative './modules/#{@module_name}_apis'\n" do
          $stdout.puts "\e[33mModule already mounted.\e[0m"
          return true
        end
      end

      File.open("#{@target_dir}/app/apis/#{@project_name}/base.rb", "r+") do |f|	
        pos = f.pos		
        rest = f.read
        f.seek pos
        f.write("require_relative './modules/") 
        f.write(@module_name)
        f.write("_apis'\n")
        f.write(rest)
      end
      return false
    end

=begin
Function to copy the module of interest to project location.
=end
    def copy_module		
      src = "#{@gem_path}/lib/modules/#{@module_name}/#{@module_name}_apis.rb"
      dest = "#{@target_dir}/app/apis/#{@project_name}/modules"
      presence = File.exists?("#{dest}/#{@module_name}_apis.rb")? true : false
      FileUtils.mkdir dest unless File.exists?(dest)
      FileUtils.cp(src,dest) unless presence
      configure_module_files
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{@project_name}/modules/#{@module_name}_apis.rb" unless presence
    end

=begin
 Function to create the necessary migrations and models. 
=end
    def create_migrations_and_models
      src = "#{@gem_path}/lib/modules/migrations"
      dest = "#{@target_dir}/db/migrate"
      copy_files(src,dest,AUTH_MIGRATE)
      if @module_name == "oauth"
        copy_files(src,dest,OAUTH_MIGRATE)
      end
      src_path = "#{@gem_path}/lib/modules/models"
      dest_path = "#{@target_dir}/app/models"   
      copy_files(src_path,dest_path,AUTH_MODELS)
      if @module_name == "oauth"
        copy_files(src_path,dest_path,OAUTH_MODELS)
      end
    end

=begin
Function to copy the module files to project location.
=end
    def copy_files(src,dest,module_model)
      module_model.each do |file|
        presence = File.exists?("#{dest}/#{file}")? true : false
        unless presence
          FileUtils.cp("#{src}/#{file}",dest)
          path = if dest.include? "app" then "app/models" else "db/migrate" end
          $stdout.puts "\e[1;32m \tcreate\e[0m\t#{path}/#{file}"
        end
      end
    end

=begin
Function to configure the module files.
=end
    def configure_module_files
      source = "#{@target_dir}/app/apis/#{@project_name}/modules/#{@module_name}_apis.rb"
      application_module = @project_name.split('_').map(&:capitalize)*''
      file = File.read(source)
      replace = file.gsub(/module Rammer/, "module #{application_module}")
      File.open(source, "w"){|f|
        f.puts replace
      }
    end

=begin
Function to add the module dependency gems to project Gemfile.
=end
    def add_gems
      file = File.open("#{@target_dir}/Gemfile", "r+")
      file.each do |line|
        while line == "gem 'oauth2'\n" do
          return
        end
      end
      File.open("#{@target_dir}/Gemfile", "a+") do |f|
        f.write("gem 'multi_json'\ngem 'oauth2'\ngem 'songkick-oauth2-provider'\ngem 'ruby_regex'\ngem 'oauth'\n")
      end
      $stdout.puts "\e[1;35m \tGemfile\e[0m\tgem 'multi_json'\n\t\tgem 'oauth2'
\t\tgem 'songkick-oauth2-provider'\n\t\tgem 'ruby_regex'\n\t\tgem 'oauth'\n"
      $stdout.puts "\e[1;32m \trun\e[0m\tbundle install"
      system("bundle install")
    end
    
=begin
Unmounts the modules by removing the respective module files.
=end
    def unmount_module
      path = "#{@target_dir}/app/apis/#{@project_name}"
      temp_file = "#{path}/tmp.rb"
      source = "#{path}/base.rb"
      delete_file = "#{path}/modules/#{@module_name}_apis.rb"
      
      File.open(temp_file, "w") do |out_file|
        File.foreach(source) do |line|
          unless line == "require_relative './modules/#{@module_name}_apis'\n"
            out_file.puts line unless line == "\t\tmount #{@module_class}\n"
          end
        end
        FileUtils.mv(temp_file, source)
      end
      
      if File.exists?(delete_file)
        FileUtils.rm(delete_file) 
        $stdout.puts "\e[1;35m\tunmounted\e[0m\t#{@module_class}" 
        $stdout.puts "\e[1;31m\tdelete\e[0m\t\tapp/apis/#{@project_name}/modules/#{@module_name}_apis.rb" 
      else
        $stdout.puts "\e[33mModule already unmounted.\e[0m"
      end
    end

=begin
Notification for oauth module api functionality access.
=end
    def oauth_message
      $stdout.puts "\e[33m
In app/apis/<APP_NAME>/modules/oauth_apis.rb
Specify redirection url to the respective authorization page into 'redirect_to_url'
and uncomment the code to enable /oauth/authorize endpoint functionality.

\e[0m"
    end
  end
end