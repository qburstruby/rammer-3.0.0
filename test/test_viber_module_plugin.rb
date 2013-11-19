require_relative './helper'

$test_file = "dummy"
$test_file_root = "#{Dir.pwd}/test"

class TestViberModulePlugin < Test::Unit::TestCase

  AUTHENTICATE_MODULE_FILES  =     ["app/apis/#{$test_file}/modules/authentication_apis.rb"]
  COMMON_FILES               =     ['db/migrate/01_create_users.rb','db/migrate/02_create_sessions.rb', 'app/models/user.rb',
                                   'app/models/session.rb', 'app/models/oauth2_authorization.rb']
  AUTHORIZE_MODULE_FILES     =     ["app/apis/#{$test_file}/modules/authorization_apis.rb"]
  OAUTH_MODULE_FILES         =     ["app/apis/#{$test_file}/modules/oauth_apis.rb",'db/migrate/03_create_owners.rb',
                                   'db/migrate/04_create_oauth2_authorizations.rb', 'db/migrate/05_create_oauth2_clients.rb',
                                   'app/models/oauth2_client.rb', 'app/models/owner.rb']
  MODULE_CLASS               =     $test_file.split('_').map(&:capitalize)*''

  def test_generator_root_module_mount_authenticate
    Dir.chdir("#{Dir.pwd}/#{$test_file}")
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthenticationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authentication", :action => "-p"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHENTICATE_MODULE_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
    COMMON_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_module_mount_authorize
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthorizationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authorization", :action => "-p"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHORIZE_MODULE_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
    COMMON_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_module_mount_oauth
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::OauthApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "oauth", :action => "-p"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    OAUTH_MODULE_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
    COMMON_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
  end

  def test_generator_root_mounting_exists
    dir_path = Dir.pwd
    module_class = "::#{MODULE_CLASS}::AuthenticationApis"
    options = { :project_name => "#{$test_file}", :module_class => module_class, 
                :module_name => "authentication", :action => "-p"}
    generator = Rammer::ModuleGenerator.new(options)
    generator.run 
    AUTHENTICATE_MODULE_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
    COMMON_FILES.each do |file|
      assert_equal(true, File.file?("#{dir_path}/#{file}"))
    end
  end
end