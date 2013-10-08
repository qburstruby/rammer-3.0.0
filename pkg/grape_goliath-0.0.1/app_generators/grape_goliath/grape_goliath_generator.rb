class GrapeGoliathGenerator < RubiGen::Base
  class FileInTheWay < StandardError
  end

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :author => nil

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    unless File.exist?(@destination_root)
      $stdout.puts "Creating goliath application under the directory #{@name}"
    else
      raise FileInTheWay, "The directory #{@name} already exists, aborting. Maybe move it out of the way before continuing?"
    end    
    extract_options
  end

  def manifest
    record do |m|
      m.directory ''
      BASEDIRS.each { |path| m.directory path }
      m.file     "Gemfile",   "Gemfile"
      m.file     "Gemfile.lock",   "Gemfile.lock"
      m.file     "Procfile",  "Procfile"
      m.file     "Rakefile",  "Rakefile"
      m.file     "application.rb",  "config/application.rb"
      m.file     "database.yml",  "config/database.yml"
      m.file     "server.rb",  "server.rb"
      m.dependency "install_rubigen_scripts", [destination_root, 'grape_goliath'],
        :shebang => options[:shebang], :collision => :force
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
    end

    # Installation skeleton.
    BASEDIRS = %w(
      app
      config
      db
      db/migrate
      app/models
    )
end