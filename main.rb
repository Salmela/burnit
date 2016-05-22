#require_relative 'src/app'
require 'sinatra'
require 'sinatra/base'

class App < Sinatra::Base
	get '/' do
	  "Hello World!"
	end

	get '/:user/' do
	  "User #{params['user']}!"
	end

	get '/:user/:repo/' do
	  "Repo #{params['user']}/#{params['repo']}!"
	end

	get '/:user/:repo/burndown' do
	  "Burndown of #{params['user']}/#{params['repo']}!"
	end

	get '/:user/:repo/user-stories' do
	  "User stories of #{params['user']}/#{params['repo']}!"
	end
end

App.run!
