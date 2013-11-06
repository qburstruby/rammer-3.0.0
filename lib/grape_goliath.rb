require "grape_goliath/version"

module GrapeGoliath
  class FileInTheWay < StandardError
  end
  class Generator
  	attr_accessor :target_dir, :project_name, 
                  :options
        BASE_DIR = ['app', 'config', 'db', 'db/migrate', 'app/models']          
    	TEMPLATE_FILES = ['Gemfile','Gemfile.lock','Procfile','Rakefile','server.rb']
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
end
