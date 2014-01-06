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
Generator class for creating application basic folder structure
=end
  class RammerGenerator
    attr_accessor :project_name, :target_dir, :module_name, :gem_path, :valid_name 

=begin
Initiliazes the following attributes : 
    project_name (application name), valid_name (boolean value for validation), target_dir (new application path)
    and gem_path (path at which the gem is installed)
=end
    def initialize(dir_name)
      @project_name   = dir_name
      @valid_name = true

      if RESERVED_WORDS.include? @project_name
        $stdout.puts "\e[1;31mError:\e[0m Invalid application name #{@project_name}. Please give a name which does not match one of the reserved rammer words."
        @valid_name = false
      end
      
      @target_dir  =  Dir.pwd + "/" + @project_name
      path = `gem which rammer`
	    @gem_path = path.split($gem_file_name,2).first + $gem_file_name        
    end
    
=begin
Creates a basic folder structure with required files and configuration setup.
=end
    def run
      unless !@valid_name || File.exists?(@project_name) || File.directory?(@project_name)
        $stdout.puts "Creating goliath application under the directory #{@project_name}"
        FileUtils.mkdir @project_name
        
        create_base_dirs
        copy_files_to_target
        setup_api_module
        copy_files_to_dir 'application.rb','config'
        copy_files_to_dir 'database.yml','config'
        $stdout.puts "\e[1;32m \trun\e[0m\tbundle install"
        system("bundle install")
      else 
        unless !@valid_name
          $stdout.puts "\e[1;31mError:\e[0m The directory #{@project_name} already exists, aborting. Maybe move it out of the way before continuing."
        end
      end
    end

    private
    
=begin
Creates the application base directories.
=end
    def create_base_dirs
      BASE_DIR.each do |dir|
        FileUtils.mkdir "#{@project_name}/#{dir}"
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{dir}"
      end
      FileUtils.mkdir "#{@project_name}/app/apis/#{@project_name}"
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{@project_name}"
    end
    
=begin
Function to setup the API modules.
=end
    def setup_api_module
      @module_name = @project_name.split('_').map(&:capitalize).join('')
      create_api_module
      config_server
    end

=begin
Function to create the API modules.
=end
    def create_api_module
      File.open("#{@project_name}/app/apis/#{@project_name}/base.rb", "w") do |f|
        f.write('module ') 
        f.puts(@module_name)
        f.write("\tclass Base < Grape::API\n\tend\nend")
      end
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{@project_name}/base.rb"
    end

=begin
Function to configure the Goliath server.
=end
    def config_server
      file = File.open("#{@project_name}/server.rb", "r+")
      file.each do |line|	   
        while line == "  def response(env)\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("\t::") 
          file.write(@module_name)
          file.write("::Base.call(env)\n")
          file.write(rest)
          $stdout.puts "\e[1;35m \tconfig\e[0m\tserver.rb"
          return
        end
      end
    end

=begin
Function to copy the template files project location.
=end
    def copy_files_to_target
      COMMON_RAMMER_FILES.each do |file|
        source = File.join("#{@gem_path}/lib/modules/common/",file)
        FileUtils.cp(source,"#{@project_name}")
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{file}"
      end
    end

=begin
Creates api modules, required files and configures the server with respect to new application.
=end
    def copy_files_to_dir(file,destination)
      FileUtils.cp("#{@gem_path}/lib/modules/common/#{file}","#{@project_name}/#{destination}")
      $stdout.puts "\e[1;32m \tcreate\e[0m\t#{destination}/#{file}"
    end
  end
end