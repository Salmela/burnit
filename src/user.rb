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
