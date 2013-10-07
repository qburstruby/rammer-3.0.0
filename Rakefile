require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/grape_goliath'

Hoe.plugin :newgem
# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'grape_goliath' do
  self.developer 'manishaharidas', 'qbruby@qburst.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }