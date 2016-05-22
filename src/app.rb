require 'sinatra'
require 'sinatra/base'

require_relative 'user'

class App < Sinatra::Base
	include User

	set :root, Proc.new { File.join(File.dirname(__FILE__), "../") }

	get '/' do
		erb :index
	end

	get '/test' do
		erb '<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>'
	end

	get '/:user/' do
		create_user_page
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
