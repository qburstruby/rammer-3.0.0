require "rubygems"
require "bundler/setup"
require 'goliath'
require 'em-synchrony/activerecord'
require 'grape'
require './tree'

class Application < Goliath::API
  def response(env)
  end
end