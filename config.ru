$:.unshift File.expand_path("../", __FILE__)
require 'sinatra'

require_relative 'src/app'

run App
