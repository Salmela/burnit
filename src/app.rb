# This file is part of Burnit.
#
# Foobar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Burnit.  If not, see <http://www.gnu.org/licenses/>.

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

	get '/:user/' do
		create_user_page
	end

	get '/:user/:repo/' do
		create_repo_page
	end

	# this should be generated per milestone not by repo
	get '/:user/:repo/burndown.svg' do
		content_type("image/svg+xml")
		create_repo_burndown_svg
	end

	get '/:user/:repo/badge.svg' do
		erb "Not implemented yet"
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
