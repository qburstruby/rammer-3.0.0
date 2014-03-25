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
Generator class for scaffolding
=end
	class ScaffoldGenerator
    attr_accessor :scaffold_name, :project_name, :gem_path, :model_class, :attributes, :data_types, 
                  :arguments, :project_class, :valid

=begin
Initiliazes the basic attributes required for scaffolding.
=end
    def initialize(options)
      @scaffold_name = to_underscore(options[:scaffold_name])
      @model_class = @scaffold_name.split('_').map(&:capitalize).join('')
      @project_name = options[:project_name]
      @project_class = @project_name.split('_').map(&:capitalize).join('')
      @arguments = options[:arguments]
      @attributes, @data_types = [],[]
      path = `gem which rammer`
      @gem_path = path.split($gem_file_name,2).first + $gem_file_name
      @valid = false
    end

=begin
Initiates scaffolding functionality by creating model, migration and api files.
=end
    def run 
      create_model_file
      create_migration if @valid==true
      enable_apis if @valid==true
    end

=begin
Generates the model file with CRED functionality.
=end
    def create_model_file
      dir = "/app/models/#{@scaffold_name}.rb"
      unless File.exists?(File.join(Dir.pwd,dir))
        File.join(Dir.pwd,dir)
        source = "#{@gem_path}/lib/modules/scaffold/model.rb"
        FileUtils.cp(source,File.join(Dir.pwd,dir))
        config_model
        @valid = true
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{dir}"
      else
        $stdout.puts "\e[1;31mError:\e[0m Model named #{@scaffold_name} already exists, aborting."
      end
    end

=begin
Configures the model file in accordance to user input.
=end
    def config_model
      source = "#{Dir.pwd}/app/models/#{@scaffold_name}.rb"
      modify_content(source, 'Model', "#{model_class}")   
      modify_content(source, '@model', "@#{@scaffold_name}")
    end

=begin
Generates migration files for the scaffold.
=end
    def create_migration
      migration_version = Time.now.to_i
      dir = "/db/migrate/#{migration_version}_create_#{@scaffold_name}s.rb"
      unless File.exists?(File.join(Dir.pwd,dir))
        source = "#{@gem_path}/lib/modules/scaffold/migration.rb"
        FileUtils.cp(source,File.join(Dir.pwd,dir))
        config_migration(migration_version)
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{dir}"
      end
    end

=begin
Configures the migration file with the required user input.
=end
    def config_migration(migration_version)
      source = "#{Dir.pwd}/db/migrate/#{migration_version}_create_#{@scaffold_name}s.rb"
      modify_content(source, 'CreateMigration', "Create#{@model_class}s")   
      modify_content(source, 'migration', "#{@scaffold_name}s") 

      @arguments.each do |value| 
        @attributes << value.split(':').first 
        @data_types << value.split(':').last 
      end

      attribute_data_types = @data_types.reverse
      @attributes.reverse.each_with_index do |value,index|
        add_attributes(source, value, attribute_data_types[index])  
      end
    end

=begin
Edits the migration file with the user specified model attributes.
=end
    def add_attributes(source,attribute,data_type)
      file = File.open(source, "r+")
      file.each do |line|
        while line == "    create_table :#{@scaffold_name}s do |t|\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("      t.#{data_type} :#{attribute}\n") 
          file.write(rest)
          break
        end
      end
    end

=begin
Generates the api file with CRED functionality apis enabled.
=end
    def enable_apis
      dir = "/app/apis/#{@project_name}/#{@scaffold_name}s/base_apis.rb"
      base_dir = "#{Dir.pwd}/app/apis/#{@project_name}/#{@scaffold_name}s"
      unless File.exists?(File.join(Dir.pwd,dir))
        FileUtils.mkdir base_dir unless File.exists?(base_dir)
        source = "#{@gem_path}/lib/modules/scaffold/base_apis.rb"
        FileUtils.cp(source,File.join(Dir.pwd,dir))
        config_apis
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{dir}"
        mount_apis
      end
    end

=begin
Configures the api file with respect to the user input.
=end
    def config_apis
      source = "#{Dir.pwd}/app/apis/#{@project_name}/#{@scaffold_name}s/base_apis.rb"
      content = ['AppName','ScaffoldName', 'Model', 'model']
      replacement = ["#{@project_class}", "#{model_class}s", "#{model_class}", "#{@scaffold_name}"]
      for i in 0..3 do
        modify_content(source, content[i], replacement[i])
      end
    end

=begin
Mounts the scaffold apis onto the application.
=end
    def mount_apis
      require_apis_to_base
      mount_class = "::#{@project_class}::#{@model_class}s::BaseApis"
      file = File.open("#{Dir.pwd}/app/apis/#{@project_name}/base.rb", "r+")
      file.each do |line|
        while line == "\tclass Base < Grape::API\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("\t\tmount ") 
          file.puts(mount_class)
          file.write(rest)
          break
        end
      end
      $stdout.puts "\e[1;35m\tmounted\e[0m\t#{mount_class}"
    end

=begin
Configures for mounting the scaffold apis.
=end
    def require_apis_to_base
      File.open("#{Dir.pwd}/app/apis/#{@project_name}/base.rb", "r+") do |f|  
        pos = f.pos   
        rest = f.read
        f.seek pos
        f.write("require_relative '#{@scaffold_name}s/base_apis'\n") 
        f.write(rest)
      end
    end

    private

=begin
Converts the string into snake case format.
=end
    def to_underscore(value)
      underscore_value = value.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
      return underscore_value
    end

=begin
Modifies the content(specified) of a file(specified) with another value(specified).
=end
    def modify_content(source, content, replace_value)
      file = File.read(source)
      replace = file.gsub(/#{content}/, replace_value)
      File.open(source, "w"){|f|
        f.puts replace       
      }
    end
  end
end