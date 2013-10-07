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
    generator = run_generator('grape_goliath', ["/home/user/grape_goliath/test/tmp/project"], sources)
    expected_root = "/home/user/grape_goliath/test/tmp/project"
    assert_equal(expected_root, generator.destination_root)
  end
  def test_generator_application_files
    generator = run_generator('grape_goliath', ["/home/user/grape_goliath/test/tmp/project"], sources)
    assert_equal(true, File.directory?("/home/user/grape_goliath/test/tmp/project/app"))
    assert_equal(true, File.directory?("/home/user/grape_goliath/test/tmp/project/db"))
    assert_equal(true, File.directory?("/home/user/grape_goliath/test/tmp/project/config"))
    assert_equal(true, File.directory?("/home/user/grape_goliath/test/tmp/project/app/models"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/config/database.yml"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/config/application.rb"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/Gemfile"))
    assert_equal(true, File.directory?("/home/user/grape_goliath/test/tmp/project/db/migrate"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/Gemfile.lock"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/Procfile"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/Rakefile"))
    assert_equal(true, File.file?("/home/user/grape_goliath/test/tmp/project/server.rb"))
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
