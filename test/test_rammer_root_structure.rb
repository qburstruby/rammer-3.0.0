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
    generator = Rammer::Generator.new(" ")
    generator.run
    assert_equal(false, File.directory?("#{dir_path}/ "))
  end

  def test_generator_reserved_directory_name
    dir_path = Dir.pwd
    generator = Rammer::Generator.new("rammer")
    generator.run
    expected_valid_name_attr = false
    assert_equal(expected_valid_name_attr, generator.valid_name)
  end

  def test_generator_root_directory
    dir_path = Dir.pwd
    FileUtils.rm_r "#{dir_path}/#{$test_file}" if File.directory?("#{dir_path}/#{$test_file}")
    generator = Rammer::Generator.new("#{$test_file}")
    generator.run
    expected_root = "#{dir_path}/#{$test_file}"    
    assert_equal(expected_root, generator.target_dir)
  end

  def test_generator_root_directory_exisiting
    dir_path = Dir.pwd
    generator = Rammer::Generator.new("#{$test_file}")
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