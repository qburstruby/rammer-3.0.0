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
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }
      # Create stubs
      m.file     "Gemfile",   "Gemfile"
      m.file     "Gemfile.lock",   "Gemfile.lock"
      m.file     "Procfile",  "Procfile"
      m.file     "Rakefile",  "Rakefile"
      m.file     "application.rb",  "config/application.rb"
      m.file     "database.yml",  "config/database.yml"
      m.file     "server.rb",  "server.rb"
      # m.template "template.rb",  "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.file     "file",         "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]

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
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      app
      config
      db
      db/migrate
      app/models
    )
end