require "rubygems"
require "bundler/setup"
require 'goliath'
require 'em-synchrony/activerecord'
require 'grape'

class Application < Goliath::API
	def response(env)
	end
end