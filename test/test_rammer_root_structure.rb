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

require_relative './helper'

$test_file = "dummy"
$test_file_root = "#{Dir.pwd}/test"

class TestRammerRootStructure < Test::Unit::TestCase

  DIR    =   ['app', 'app/apis', 'config', 'db', 'db/migrate', 'app/models']
  FILES  =   ['Gemfile','Gemfile.lock','Procfile','Rakefile','server.rb', 'tree.rb',
              "app/apis/#{$test_file}/base.rb", 'config/application.rb', 'config/database.yml']

  def test_generator_directory_name
    Dir.chdir("#{$test_file_root}")
    dir_path = Dir.pwd
    generator = Rammer::RammerGenerator.new(" ")
    generator.run
    assert_equal(false, File.directory?("#{dir_path}/ "))
  end

  def test_generator_reserved_directory_name
    dir_path = Dir.pwd
    generator = Rammer::RammerGenerator.new("rammer")
    generator.run
    expected_valid_name_attr = false
    assert_equal(expected_valid_name_attr, generator.valid_name)
  end

  def test_generator_root_directory
    dir_path = Dir.pwd
    FileUtils.rm_r "#{dir_path}/#{$test_file}" if File.directory?("#{dir_path}/#{$test_file}")
    generator = Rammer::RammerGenerator.new("#{$test_file}")
    generator.run
    expected_root = "#{dir_path}/#{$test_file}"    
    assert_equal(expected_root, generator.target_dir)
  end

  def test_generator_root_directory_exisiting
    dir_path = Dir.pwd
    generator = Rammer::RammerGenerator.new("#{$test_file}")
    generator.run
    assert_equal(true, File.directory?("#{dir_path}/#{$test_file}"))
  end

  def test_generator_root_folder_structure    
    dir_path = Dir.pwd 
    DIR.each do |dir| 
      assert_equal(true, File.directory?("#{dir_path}/#{$test_file}/#{dir}"))
    end
    FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{$test_file}/#{file}"))
    end
  end
end