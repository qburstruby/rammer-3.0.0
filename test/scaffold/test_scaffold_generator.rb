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

require_relative '../helper'

$test_file = "dummy"
$test_file_root = "#{Dir.pwd}/test"
$scaffold_name = "test"

SCAFFOLD_FILES = ["app/models/#{$scaffold_name}.rb","app/apis/#{$test_file}/#{$scaffold_name}s/base_apis.rb"]

class TestScaffoldGenerator < Test::Unit::TestCase
	def test_generator_scaffold_folder
	    Dir.chdir("#{$test_file_root}/#{$test_file}")
		options = { :project_name => $test_file, :scaffold_name => $scaffold_name, :arguments => ['name:string']}
	    scaffold_generator = Rammer::ScaffoldGenerator.new(options)
	    scaffold_generator.run 
	    dir_path = Dir.pwd
	    SCAFFOLD_FILES.each do |file|
	      assert_equal(true, File.file?("#{dir_path}/#{file}"))
	    end
	    Dir.entries('db/migrate/.').each do |file|
	    	assert true if file.include?('create_#{scaffold_name}s')
	    end
	end

	def test_generator_scaffold_folder_duplicate
		Dir.chdir("#{$test_file_root}/#{$test_file}")
		options = { :project_name => $test_file, :scaffold_name => $scaffold_name, :arguments => ['name:string']}
	    scaffold_generator = Rammer::ScaffoldGenerator.new(options)
	    scaffold_generator.run 
	    expected_valid_attr = false
    	assert_equal(expected_valid_attr, scaffold_generator.valid)
	end
end