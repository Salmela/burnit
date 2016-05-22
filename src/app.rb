require 'sinatra'
require 'sinatra/base'

require_relative 'user'
require_relative 'repo'

class App < Sinatra::Base
	include User
	include Repo

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
		if search_query and search_query.length > 0
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
		create_repo_page
	end

	get '/:user/:repo/burndown' do
		create_burndown_page
	end

	get '/:user/:repo/user-stories' do
		create_user_stories_page
	end

	set :public_folder, settings.root + '/static'

	not_found do
		status 404
		erb 'not found'
	end
end
