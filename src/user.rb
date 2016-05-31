# Burnit is free software: you can redistribute it and/or modify
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

require_relative 'github_api'

class GithubRepo
	def initialize(data)
		@data = data
	end

	def name
		@data['name']
	end

	def description
		@data['description']
	end
end

module User
	def create_user_page
		repos = Array.new
		uri = URI("https://api.github.com/users/#{params['user']}/repos")
		array = GithubApi.get_default.load(uri)
		if !array
			array = Array.new
		end
		array.each do |repo|
			repos.push(GithubRepo.new(repo))
		end
		puts params['user']
		erb :user_view, :locals => {
			:repos => repos, :user => params['user']}
	end
end
