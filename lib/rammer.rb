require "rammer/version"
require 'fileutils'

$gem_file_name = "rammer-"+Rammer::VERSION

module Rammer
  #Generator class for folder structure
  class Generator
    attr_accessor :project_name, :target_dir, :module_name, :gem_path, :valid_name
    BASE_DIR = ['app', 'app/apis', 'config', 'db', 'db/migrate', 'app/models']          
    TEMPLATE_FILES = ['Gemfile','Gemfile.lock','Procfile','Rakefile','server.rb', 'tree.rb']
    RESERVED_WORDS = ['rammer', 'viber', 'test', 'lib', 'template', 'authorization', 'authentication', 'app', 'apis', 'models', 'migrate', 'oauth', 'oauth2']

    def initialize(dir_name)
      self.project_name   = dir_name
      if self.project_name.nil? || self.project_name.squeeze.strip == ""
        $stdout.puts "\e[1;31mError:\e[0m Please specify an application name."
      elsif self.project_name
        RESERVED_WORDS.each do |name| 
          if name == self.project_name
            $stdout.puts "\e[1;31mError:\e[0m Invalid application name #{project_name}. Please give a name which does not match one of the reserved rammer words."
            self.valid_name = false
            break
          else
            self.valid_name = true
          end
        end
      end
      self.target_dir  =  Dir.pwd + "/" + self.project_name
      path = `gem which rammer`
	    self.gem_path = path.split($gem_file_name,2).first + $gem_file_name        
    end

    def run
      unless !self.valid_name || File.exists?(project_name) || File.directory?(project_name)
        $stdout.puts "Creating goliath application under the directory #{project_name}"
        FileUtils.mkdir project_name
        create_base_dirs
        copy_files_to_target
        setup_api_module
        copy_files_to_dir 'application.rb','config'
        copy_files_to_dir 'database.yml','config'
        $stdout.puts "\e[33mRun `bundle install` to install missing gems.\e[0m"
      else 
        unless !self.valid_name
          $stdout.puts "\e[1;31mError:\e[0m The directory #{project_name} already exists, aborting. Maybe move it out of the way before continuing."
        end
      end
    end

    private

    def create_base_dirs
      BASE_DIR.each do |dir|
        FileUtils.mkdir "#{project_name}/#{dir}"
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{dir}"
      end
      FileUtils.mkdir "#{project_name}/app/apis/#{project_name}"
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{project_name}"
    end

    def setup_api_module
      self.module_name = project_name.split('_').map(&:capitalize).join('')
      create_api_module
      config_server
    end

    def create_api_module
      File.open("#{project_name}/app/apis/#{project_name}/base.rb", "w") do |f|
        f.write('module ') 
        f.puts(module_name)
        f.write("\tclass Base < Grape::API\n\tend\nend")
      end
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{project_name}/base.rb"
    end

    def config_server
      file = File.open("#{project_name}/server.rb", "r+")
      file.each do |line|	   
        while line == "  def response(env)\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("\t::") 
          file.write(module_name)
          file.write("::Base.call(env)\n")
          file.write(rest)
          $stdout.puts "\e[1;35m \tconfig\e[0m\tserver.rb"
          return
        end
      end
    end

    def copy_files_to_target
      TEMPLATE_FILES.each do |file|
        source = File.join("#{gem_path}/lib/template/",file)
        FileUtils.cp(source,"#{project_name}")
        $stdout.puts "\e[1;32m \tcreate\e[0m\t#{file}"
      end
    end

    def copy_files_to_dir(file,destination)
      FileUtils.cp("#{gem_path}/lib/template/#{file}","#{project_name}/#{destination}")
      $stdout.puts "\e[1;32m \tcreate\e[0m\t#{destination}/#{file}"
    end
  end
  #Generator class for viber commands 
  class ModuleGenerator
    attr_accessor :target_dir, :project_name, :module_class, :options, :module_name, :gem_path, :action
    AUTH_MIGRATE = ['01_create_users.rb','02_create_sessions.rb']
    OAUTH_MIGRATE = ['03_create_owners.rb', '04_create_oauth2_authorizations.rb', '05_create_oauth2_clients.rb']
    AUTH_MODELS = ['user.rb', 'session.rb', 'oauth2_authorization.rb']
    OAUTH_MODELS = ['oauth2_client.rb', 'owner.rb']

    def initialize(options)
      self.options = options
      self.project_name = options[:project_name]
      self.module_class = options[:module_class]
      self.module_name = options[:module_name]
      self.action = options[:action]
      self.target_dir = Dir.pwd
      path = `gem which rammer`
      self.gem_path = path.split($gem_file_name,2).first + "/" + $gem_file_name
    end

    def run
      case action
      when "-p","-plugin"
        flag = require_module_to_base
        mount_module unless flag
        copy_module
        create_migrations
        copy_model_files
        add_gems
        oauth_message if module_name == "oauth" && !flag
      when "-u","-unplug"
        unmount_module
      end
    end

    def mount_module
      file = File.open("#{target_dir}/app/apis/#{project_name}/base.rb", "r+")
      file.each do |line|
        while line == "\tclass Base < Grape::API\n" do
          pos = file.pos
          rest = file.read
          file.seek pos
          file.write("\t\tmount ") 
          file.puts(module_class)
          file.write(rest)
          break
        end
      end
      $stdout.puts "\e[1;35m\tmounted\e[0m\t#{module_class}"
    end

    def require_module_to_base
      file = File.open("#{target_dir}/app/apis/#{project_name}/base.rb", "r+")
      file.each do |line|
        while line == "require_relative './modules/#{module_name}_apis'\n" do
          $stdout.puts "\e[33mModule already mounted.\e[0m"
          return true
        end
      end
      File.open("#{target_dir}/app/apis/#{project_name}/base.rb", "r+") do |f|	
        pos = f.pos		
        rest = f.read
        f.seek pos
        f.write("require_relative './modules/") 
        f.write(module_name)
        f.write("_apis'\n")
        f.write(rest)
      end
      return false
    end

    def copy_module		
      src = "#{gem_path}/lib/template/#{module_name}_apis.rb"
      dest = "#{target_dir}/app/apis/#{project_name}/modules"
      presence = File.exists?("#{dest}/#{module_name}_apis.rb")? true : false
      FileUtils.mkdir dest unless File.exists?(dest)
      FileUtils.cp(src,dest) unless presence
      configure_module_files
      $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/apis/#{project_name}/modules/#{module_name}_apis.rb" unless presence
    end

    def create_migrations
      src = "#{gem_path}/lib/template"
      dest = "#{target_dir}/db/migrate"
      case module_name
      when "authentication", "authorization"  	
        common_migrations(src,dest)
      when "oauth"
        common_migrations(src,dest)
        OAUTH_MIGRATE.each do |file|		
          presence = File.exists?("#{dest}/#{file}")? true : false
          unless presence
            FileUtils.cp("#{src}/#{file}",dest)
            $stdout.puts "\e[1;32m \tcreate\e[0m\tdb/migrate/#{file}"
          end
        end
      end
    end

    def common_migrations(src,dest)
      AUTH_MIGRATE.each do |file|		
        presence = File.exists?("#{dest}/#{file}")? true : false
        unless presence
          FileUtils.cp("#{src}/#{file}",dest)
          $stdout.puts "\e[1;32m \tcreate\e[0m\tdb/migrate/#{file}"
        end
      end
    end

    def common_models(src,dest)
      AUTH_MODELS.each do |file|
        presence = File.exists?("#{dest}/#{file}")? true : false
        unless presence
          FileUtils.cp("#{src}/#{file}",dest)
          $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/models/#{file}"
        end
      end
    end

    def copy_model_files
      src = "#{gem_path}/lib/template"
      dest = "#{target_dir}/app/models"
      case module_name
      when "authentication", "authorization"  	
        common_models(src,dest)
      when "oauth"
        common_models(src,dest)
        OAUTH_MODELS.each do |file|		
          presence = File.exists?("#{dest}/#{file}")? true : false
          unless presence
            FileUtils.cp("#{src}/#{file}",dest)
            $stdout.puts "\e[1;32m \tcreate\e[0m\tapp/models/#{file}"
          end
        end
      end
    end

    def configure_module_files
      file = File.read("#{target_dir}/app/apis/#{project_name}/modules/#{module_name}_apis.rb")
      replace = file.gsub(/module Rammer/, "module #{project_name.split('_').map(&:capitalize)*''}")
      File.open("#{target_dir}/app/apis/#{project_name}/modules/#{module_name}_apis.rb", "w"){|f|
        f.puts replace
      }
    end

    def add_gems
      file = File.open("#{target_dir}/Gemfile", "r+")
      file.each do |line|
        while line == "gem 'oauth2'\n" do
          return
        end
      end
      File.open("#{target_dir}/Gemfile", "a+") do |f|
        f.write("gem 'multi_json'\ngem 'oauth2'\ngem 'songkick-oauth2-provider'\ngem 'ruby_regex'\ngem 'oauth'\n")
      end
      $stdout.puts "\e[1;35m \tGemfile\e[0m\tgem 'multi_json'\n\t\tgem 'oauth2'
\t\tgem 'songkick-oauth2-provider'\n\t\tgem 'ruby_regex'\n\t\tgem 'oauth'\n"
      $stdout.puts "\e[1;32m \trun\e[0m\tbundle install"
      system("bundle install")
    end

    def unmount_module
      temp_file = "#{target_dir}/app/apis/#{project_name}/tmp.rb"
      source = "#{target_dir}/app/apis/#{project_name}/base.rb"
      delete_file = "#{target_dir}/app/apis/#{project_name}/modules/#{module_name}_apis.rb"
      File.open(temp_file, "w") do |out_file|
        File.foreach(source) do |line|
          unless line == "require_relative './modules/#{module_name}_apis'\n"
            out_file.puts line unless line == "\t\tmount #{module_class}\n"
          end
        end
        FileUtils.mv(temp_file, source)
      end
      if File.exists?(delete_file)
        FileUtils.rm(delete_file) 
        $stdout.puts "\e[1;35m\tunmounted\e[0m\t#{module_class}" 
        $stdout.puts "\e[1;31m\tdelete\e[0m\t\tapp/apis/#{project_name}/modules/#{module_name}_apis.rb" 
      else
        $stdout.puts "\e[33mModule already unmounted.\e[0m"
      end
    end

    def oauth_message
      $stdout.puts "\e[33m
In app/apis/<APP_NAME>/modules/oauth_apis.rb
Specify redirection url to the respective authorization page into 'redirect_to_url'
and uncomment the code to enable /oauth/authorize endpoint functionality.

\e[0m"
    end
  end
end

