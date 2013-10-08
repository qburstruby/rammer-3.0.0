require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestGrapeGoliathGenerator < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
  end

  def teardown
    bare_teardown
  end

  def test_generator_root_directory    
    dir_path = Dir.getwd
    FileUtils.rm_r "#{dir_path}/test/dummy" if File.directory?("#{dir_path}/test/dummy")
    generator = run_generator('grape_goliath', ["#{dir_path}/test/dummy"], sources)
    expected_root = "#{dir_path}/test/dummy"    
    assert_equal(expected_root, generator.destination_root)
  end
  
  def test_generator_application_files    
    dir_path = Dir.getwd
    FileUtils.rm_r "#{dir_path}/test/test_folder" if File.directory?("#{dir_path}/test/test_folder")
    generator = run_generator('grape_goliath', ["#{dir_path}/test/test_folder"], sources)
    assert_equal(true, File.directory?("#{dir_path}/test/test_folder/app"))
    assert_equal(true, File.directory?("#{dir_path}/test/test_folder/db"))
    assert_equal(true, File.directory?("#{dir_path}/test/test_folder/config"))
    assert_equal(true, File.directory?("#{dir_path}/test/test_folder/app/models"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/config/database.yml"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/config/application.rb"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/Gemfile"))
    assert_equal(true, File.directory?("#{dir_path}/test/test_folder/db/migrate"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/Gemfile.lock"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/Procfile"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/Rakefile"))
    assert_equal(true, File.file?("#{dir_path}/test/test_folder/server.rb"))
  end

  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))
    ]
  end

  def generator_path
    "app_generators"
  end
end
