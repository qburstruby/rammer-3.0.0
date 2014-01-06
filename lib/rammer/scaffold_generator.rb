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
	class ScaffoldGenerator
    attr_accessor :scaffold_name, :project_name, :gem_path, :model_class, :attributes, :data_types, :arguments

    def initialize(options)
      @scaffold_name = to_underscore(options[:scaffold_name])
      @model_class = @scaffold_name.split('_').map(&:capitalize).join('')
      @project_name = options[:project_name]
      @arguments = options[:arguments]
      @attributes, @data_types = [],[]
      path = `gem which rammer`
      @gem_path = path.split($gem_file_name,2).first + $gem_file_name
    end

    def run 
      create_model_file
      create_migration
    end

    def create_model_file
      unless File.exists?("#{Dir.pwd}/app/models/#{@scaffold_name}.rb")
        source = "#{@gem_path}/lib/modules/scaffold/model.rb"
        FileUtils.cp(source,"#{Dir.pwd}/app/models/#{@scaffold_name}.rb")
        config_model
        $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/models/#{@scaffold_name}.rb"
      else
        $stdout.puts "\e[1;31mError:\e[0m Model named #{@scaffold_name} already exists, aborting."
      end
    end

    def config_model
      source = "#{Dir.pwd}/app/models/#{@scaffold_name}.rb"
      modify_content(source, 'Model', "#{model_class}")   
      modify_content(source, '@model', "@#{@scaffold_name}")
    end

    def create_migration
      @arguments.each do |value| 
        @attributes << value.split(':').first 
        @data_types << value.split(':').last 
      end

      migration_version = Time.now.to_i
      unless File.exists?("#{Dir.pwd}/db/migrate/#{migration_version}_create_#{@scaffold_name}s.rb")
        source = "#{@gem_path}/lib/modules/scaffold/migration.rb"
        FileUtils.cp(source,"#{Dir.pwd}/db/migrate/#{migration_version}_create_#{@scaffold_name}s.rb")
        config_migration(migration_version)
        $stdout.puts "\e[1;32m \tcreate\e[0m\tdb/migrate/#{migration_version}_create_#{@scaffold_name}s.rb"
      end
    end

    def config_migration(migration_version)
      source = "#{Dir.pwd}/db/migrate/#{migration_version}_create_#{@scaffold_name}s.rb"
      modify_content(source, 'CreateMigration', "Create#{@model_class}s")   
      modify_content(source, 'migration', "#{@scaffold_name}s") 

      attribute_data_types = @data_types.reverse
      @attributes.reverse.each_with_index do |value,index|
        add_attributes(source, value, attribute_data_types[index])  
      end
    end

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

    private

    def to_underscore(value)
      underscore_value = value.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
      return underscore_value
    end

    def modify_content(source, content, replace_value)
      file = File.read(source)
      replace = file.gsub(/#{content}/, replace_value)
      File.open(source, "w"){|f|
        f.puts replace       
      }
    end
  end
end