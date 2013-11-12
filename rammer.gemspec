# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rammer/version'

Gem::Specification.new do |spec|
  spec.name          = "rammer"
  spec.version       = Rammer::VERSION
  spec.authors       = ["manishaharidas"]
  spec.email         = ["manisha@qburst.com"]
  spec.summary       = %q{Grape+Goliath application generator gem}
  spec.description   = %q{rammer is a gem which creates an application with tree structure specified for a Goliath application having Grape framework.}
  spec.homepage      = "http://github.com/qburstruby/rammer"
  spec.license       = "MIT"

  spec.files         = ["lib/rammer.rb",
                        "lib/rammer/version.rb",
                        "lib/template/01_create_users.rb",
                        "lib/template/02_create_sessions.rb",
                        "lib/template/03_create_owners.rb",
                        "lib/template/04_create_oauth2_authorizations.rb",
                        "lib/template/05_create_oauth2_clients.rb",
                        "lib/template/Gemfile",
                        "lib/template/Gemfile.lock",
                        "lib/template/Procfile",
                        "lib/template/Rakefile",
                        "lib/template/application.rb",
                        "lib/template/authentication_apis.rb",
                        "lib/template/authorization_apis.rb",
                        "lib/template/database.yml",
                        "lib/template/oauth2_authorization.rb",
                        "lib/template/oauth2_client.rb",
                        "lib/template/oauth_apis.rb",
                        "lib/template/owner.rb",
                        "lib/template/server.rb",
                        "lib/template/session.rb",
                        "lib/template/tree.rb",
                        "lib/template/user.rb",
                        "Gemfile",
                        "LICENSE.txt",
                        "README.md",
                        "Rakefile",
                        "rammer.gemspec"
                      ]
  spec.executables   = ["rammer","viber"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"
end
