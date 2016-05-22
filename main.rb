#require_relative 'src/app'
require 'sinatra'
require 'sinatra/base'

class App < Sinatra::Base
	get '/' do
	  "Hello World!"
	end

	get '/burndown' do
	  "Burndown!"
	end

	get '/user-stories' do
	  "User stories!"
	end
end

App.run!
