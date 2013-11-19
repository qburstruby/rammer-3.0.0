require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.test_files = FileList.new('test/**/test_*.rb') do |list|
    list.exclude 'test/test_helper.rb'
    list.exclude 'test/fixtures/**/*.rb'
  end
  test.libs << 'test'
  test.verbose = true
end
