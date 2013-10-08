# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "grape_goliath"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["manishaharidas"]
  s.date = "2013-09-23"
  s.description = "grape_goliath is a gem which creates an application with tree structure specified for a Goliath application having Grape framework."
  s.email = ["qbruby@qburst.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", 
    "Manifest.txt", 
    "PostInstall.txt", 
    "README.rdoc", 
    "Rakefile", 
    "lib/grape_goliath.rb", 
    "script/console", 
    "script/destroy", 
    "script/generate", 
    "test/test_grape_goliath.rb", 
    "test/test_helper.rb", 
    "test/test_grape_goliath_generator.rb", 
    "test/test_generator_helper.rb",
    "app_generators/grape_goliath/grape_goliath_generator.rb",
    "bin/grape_goliath",
    "app_generators/grape_goliath/templates/Gemfile",
    "app_generators/grape_goliath/templates/Gemfile.lock",
    "app_generators/grape_goliath/templates/Procfile",
    "app_generators/grape_goliath/templates/Rakefile",
    "app_generators/grape_goliath/templates/application.rb",
    "app_generators/grape_goliath/templates/database.yml",
    "app_generators/grape_goliath/templates/server.rb ",
    ".gemtest"]
  s.homepage = "http://github.com/qburstruby/grape_goliath"
  s.licenses = ["MIT"]
  s.post_install_message = "PostInstall.txt"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "grape_goliath"
  s.rubygems_version = "1.8.25"
  s.summary = "Grape+Goliath application generator gem"
  s.test_files = ["test/test_grape_goliath_generator.rb", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_grape_goliath.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_development_dependency(%q<hoe>, ["~> 3.7"])
    else
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_dependency(%q<hoe>, ["~> 3.7"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<newgem>, [">= 1.5.3"])
    s.add_dependency(%q<hoe>, ["~> 3.7"])
  end
end
