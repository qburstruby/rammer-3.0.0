# coding: utf-8

=begin
**************************************************************************
* The MIT License (MIT)

* Copyright (c) 2013-2014 QBurst Technologies Inc.

* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.

**************************************************************************
=end

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rammer/version'

Gem::Specification.new do |spec|
  spec.name          = "rammer"
  spec.version       = Rammer::VERSION
  spec.authors       = ["manishaharidas"]
  spec.email         = ["manisha@qburst.com"]
  spec.summary       = %q{Rammer is a framework dedicated to build high performance Async API servers on top of non-blocking (asynchronous) Ruby web server called Goliath.}
  spec.description   = %q{Rammer is a framework dedicated to build high performance Async API servers on top of non-blocking (asynchronous) Ruby web server called Goliath. Rammer APIs are designed on top of REST-like API micro-framework Grape. Rammer is modular and integrates a powerful CLI called Viber to plug in and out its modules.}
  spec.homepage      = "http://github.com/qburstruby/rammer"
  spec.license       = "MIT"

  spec.files         = ["lib/rammer.rb",
                        "lib/rammer/version.rb",
                        "lib/rammer/rammer_generator.rb",
                        "lib/rammer/module_generator.rb",
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
                        "test/helper.rb",
                        "test/test_rammer_root_structure.rb",
                        "test/test_viber_module_plugin.rb",
                        "test/test_viber_module_unplug.rb",
                        "Gemfile",
                        "LICENSE.txt",
                        "README.md",
                        "Rakefile",
                        "rammer.gemspec"
                      ]
  spec.executables   = ["rammer","viber"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.4.0.rc.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "shoulda"
  spec.add_development_dependency "simplecov"
end
