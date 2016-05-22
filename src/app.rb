require 'sinatra'
require 'sinatra/base'

require_relative 'user'

class App < Sinatra::Base
	include User

	set :root, Proc.new { File.join(File.dirname(__FILE__), "../") }

	def search(search_query)
		array = search_query.split('/')
		if array.length == 1 or array[1].empty?
			redirect(to("/#{array[0]}/"))
		else
			redirect(to("/#{array[0]}/#{array[1]}/"))
		end
	end

	get '/' do
		search_query = params['search']
		if search_query
			search(search_query)
		end
		erb :index_view
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
