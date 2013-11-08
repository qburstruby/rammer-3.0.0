require "grape_goliath/version"
require 'fileutils'
module GrapeGoliath
  	class FileInTheWay < StandardError
  	end
  	class Generator
	  	attr_accessor :target_dir, :project_name, :module_name
        BASE_DIR = ['app', 'app/apis', 'config', 'db', 'db/migrate', 'app/models']          
    	TEMPLATE_FILES = ['Gemfile','Gemfile.lock','Procfile','Rakefile','server.rb', 'tree.rb']
    	def initialize(dir_name)
			self.project_name   = dir_name
			if self.project_name.nil? || self.project_name.squeeze.strip == ""
		        raise NoGitHubRepoNameGiven
		    else
		        path = File.split(self.project_name)

		        if path.size > 1
		          extracted_directory = File.join(path[0..-1])
		          self.project_name = path.last
		        end
		    end
		    self.target_dir  =  self.project_name
		end

	    def run
	      unless File.exists?(target_dir) || File.directory?(target_dir)
	      	$stdout.puts "Creating goliath application under the directory #{target_dir}"
	        FileUtils.mkdir target_dir
	        create_base_dirs
	        copy_files_to_target
	        setup_api_module
	        copy_files_to_dir 'application.rb','config'
	        copy_files_to_dir 'database.yml','config'
	        puts "\e[33mRun `bundle install` to install missing gems.\e[0m"
	      else
	        raise FileInTheWay, "The directory #{target_dir} already exists, aborting. Maybe move it out of the way before continuing?"
	      end
	    end

	    private

	    def create_base_dirs
	    	BASE_DIR.each do |dir|
	    		FileUtils.mkdir "#{target_dir}/#{dir}"
	    		$stdout.puts "\tcreate\t/#{dir}"
	    	end
	    	FileUtils.mkdir "#{target_dir}/app/apis/#{target_dir}"
	    	$stdout.puts "\tcreate\t/app/apis/#{target_dir}"
	    end

	    def setup_api_module
	    	self.module_name = target_dir.split.map(&:capitalize).join(' ')
	    	create_api_module
	    	config_server
	    end

	    def create_api_module
	    	File.open("#{target_dir}/app/apis/#{target_dir}/base.rb", "w") do |f|
	    		f.write('module ') 
	    		f.puts(module_name)
	    		f.write("\tclass Base < Grape::API\n\tend\nend")
	    	end
	    	$stdout.puts "\tcreate\t/app/apis/#{target_dir}/base.rb"
	    end

	    def config_server
	    	file = File.open("#{target_dir}/server.rb", "r+")
	    	file.each do |line|	   
		        while line == "\tdef response(env)\n" do
		            pos = file.pos
		            rest = file.read
		            file.seek pos
		            file.write("\t\t::") 
		            file.write(module_name)
		            file.write("::Base.call(env)\n")
		            file.write(rest)
		            return
		        end
			end
			$stdout.puts "\tconfig\t/server.rb"
	    end

	    def copy_files_to_target
	    	TEMPLATE_FILES.each do |file|
	    		source = File.join("grape_goliath/lib/template/",file)
		    	FileUtils.cp(source,"#{target_dir}")
		        $stdout.puts "\tcreate\t/#{file}"
		    end
	    end

	    def copy_files_to_dir(file,destination)
	    	FileUtils.cp("grape_goliath/lib/template/#{file}","#{target_dir}/#{destination}")
	        $stdout.puts "\tcreate\t/#{destination}/#{file}"
	    end
  	end

  	class ModuleGenerator
	  	attr_accessor :target_dir, :module_class, :options, :module_name, :gem_path
	  	AUTH_MIGRATE = ['01_create_users.rb','02_create_sessions.rb']
	    OAUTH_MIGRATE = ['03_create_owners.rb', '04_create_oauth2_authorizations.rb', '05_create_oauth2_clients.rb']
	    AUTH_MODELS = ['user.rb', 'session.rb', 'oauth2_authorization.rb']
	    OAUTH_MODELS = ['oauth2_client.rb', 'owner.rb']
	  	def initialize(options)
	  		self.options = options
	  		self.target_dir = options[:target_dir]
	  		self.module_class = options[:module_class]
	  		self.module_name = options[:module_name]
	  		path = `gem which grape_goliath`
	  		self.gem_path = path.split("/.rvm",2).first
	  	end

	  	def run
	  		file = File.open("#{Dir.pwd}/app/apis/#{target_dir}/base.rb", "r+")
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
			$stdout.puts "\tmounted\t #{module_class}"
			require_module_to_base
			copy_module
			create_migrations
			copy_model_files
		end

		def require_module_to_base
			File.open("#{Dir.pwd}/app/apis/#{target_dir}/base.rb", "r+") do |f|	
				pos = f.pos		
				rest = f.read
				f.seek pos
				f.write("require_relative './modules/") 
		        f.write(module_name)
		        f.write("_apis'\n")
		        f.write(rest)
			end
		end

		def copy_module		
			src = "#{gem_path}/grape_goliath/lib/template/#{module_name}_apis.rb"
			dest = "#{Dir.pwd}/app/apis/#{target_dir}/modules"
			presence = File.exists?("#{dest}/#{module_name}_apis.rb")? true : false
			FileUtils.mkdir dest unless File.exists?(dest)
			FileUtils.cp(src,dest) unless presence
			configure_module_files
			$stdout.puts "\tcreate\t/#{target_dir}/modules/#{module_name}/#{module_name}_apis.rb" unless presence
			add_gems
	  	end

	  	def create_migrations
	  		src = "#{gem_path}/grape_goliath/lib/template"
	  		dest = "#{Dir.pwd}/db/migrate"
	  		case module_name
	  		when "authentication", "authorization"  	
	  			common_migrations(src,dest)
	  		when "oauth"
	  			common_migrations(src,dest)
	  			OAUTH_MIGRATE.each do |file|		
	  				presence = File.exists?("#{dest}/#{file}")? true : false
	  				unless presence
		  				FileUtils.cp("#{src}/#{file}",dest)
		  				$stdout.puts "\tcreate\t#{dest}/#{file}"
	  				end
	  			end
	  		end
	  	end

	  	def common_migrations(src,dest)
	  		AUTH_MIGRATE.each do |file|		
  				presence = File.exists?("#{dest}/#{file}")? true : false
  				unless presence
	  				FileUtils.cp("#{src}/#{file}",dest)
	  				$stdout.puts "\tcreate\t#{dest}/#{file}"
  				end
  			end
	  	end

	  	def common_models(src,dest)
	  		AUTH_MODELS.each do |file|
  				presence = File.exists?("#{dest}/#{file}")? true : false
  				unless presence
	  				FileUtils.cp("#{src}/#{file}",dest)
	  				$stdout.puts "\tcreate\t#{dest}/#{file}"
  				end
  			end
	  	end

	  	def copy_model_files
	  		src = "#{gem_path}/grape_goliath/lib/template"
	  		dest = "#{Dir.pwd}/app/models"
	  		case module_name
	  		when "authentication", "authorization"  	
	  			common_models(src,dest)
	  		when "oauth"
	  			common_models(src,dest)
	  			OAUTH_MODELS.each do |file|		
	  				presence = File.exists?("#{dest}/#{file}")? true : false
	  				unless presence
		  				FileUtils.cp("#{src}/#{file}",dest)
		  				$stdout.puts "\tcreate\t#{dest}/#{file}"
	  				end
	  			end
	  		end
	  	end

	  	def configure_module_files
	  		file = File.read("#{Dir.pwd}/app/apis/#{target_dir}/modules/#{module_name}_apis.rb")
	  		replace = file.gsub(/module GrapeGoliath/, "module #{target_dir.split.map(&:capitalize)*' '}")
	  		File.open("#{Dir.pwd}/app/apis/#{target_dir}/modules/#{module_name}_apis.rb", "w"){|f|
	  			f.puts replace
	  		}
	  	end

	  	def add_gems
	  		file = File.open("#{Dir.pwd}/Gemfile", "r+")
	  		file.each do |line|
	  			while line == "gem 'oauth2'\n" do
	  				return
	  			end
	  		end
	  		File.open("#{Dir.pwd}/Gemfile", "a+") do |f|
	  			f.write("gem 'multi_json'\ngem 'oauth2'\ngem 'songkick-oauth2-provider'\ngem 'ruby_regex'")
	  		end
  			$stdout.puts "\tGemfile\tgem 'multi_json'\n\t\tgem 'oauth2'
\t\tgem 'songkick-oauth2-provider'\n\t\tgem 'ruby_regex'"
	  	end
  	end
end
