require_relative './helper'

$test_file = "dummy"
$test_file_root = "#{Dir.pwd}/test"

class TestViberModuleUnmplug < Test::Unit::TestCase

  AUTHENTICATE_MODULE_FILES  =     ["app/apis/#{$test_file}/modules/authentication_apis.rb"]
  AUTHORIZE_MODULE_FILES     =     ["app/apis/#{$test_file}/modules/authorization_apis.rb"]
  OAUTH_MODULE_FILES         =     ["app/apis/#{$test_file}/modules/oauth_apis.rb"]
  MODULE_CLASS               =     $test_file.split('_').map(&:capitalize)*''

  def test_generator_root_module_unmount_authenticate
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthenticationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authentication", :action => "-u"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHENTICATE_MODULE_FILES.each do |file|
      assert_equal(false, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_module_unmount_authorize
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthorizationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authorization", :action => "-u"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHORIZE_MODULE_FILES.each do |file|
      assert_equal(false, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_module_unmount_oauth
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::OauthApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "oauth", :action => "-u"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    OAUTH_MODULE_FILES.each do |file|
      assert_equal(false, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_unmouting_executed
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthenticationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authentication", :action => "-u"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHENTICATE_MODULE_FILES.each do |file|
      assert_equal(false, File.file?("#{dir_path}/#{file}"))
    end
  end
end