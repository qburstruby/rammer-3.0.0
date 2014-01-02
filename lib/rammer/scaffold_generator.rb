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

$gem_file_name = "rammer-"+Rammer::VERSION

module Rammer
	class ScaffoldGenerator
    attr_accessor :scaffold_name, :project_name, :gem_path

    def initialize(options)
      @module_name = options[:scaffold_name]
      @project_name = options[:project_name]
      path = `gem which rammer`
      @gem_path = path.split($gem_file_name,2).first + "/" + $gem_file_name
    end

    def run 
      # FileUtils.mkdir @module_name
      # $stdout.puts "\e[1;32m \tcreate\e[0m\t#{@module_name}"
    end
  end
end