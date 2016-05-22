require 'sinatra'
require 'sinatra/base'

class App < Sinatra::Base
	set :root, Proc.new { File.join(File.dirname(__FILE__), "../") }

	get '/' do
		erb :index
	end

	get '/:user/' do
		erb "User #{params['user']}!"
	end

	get '/:user/:repo/' do
		erb "Repo #{params['user']}/#{params['repo']}!"
	end

	get '/:user/:repo/burndown' do
		erb "Burndown of #{params['user']}/#{params['repo']}!"
	end

	get '/:user/:repo/user-stories' do
		erb "User stories of #{params['user']}/#{params['repo']}!"
	end

	set :public_folder, settings.root + '/static'

	not_found do
		status 404
		erb 'not found'
	end
end
