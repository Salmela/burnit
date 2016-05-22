require_relative 'github_api'

module Repo
	def create_repo_page
		erb :repo_view
	end
	def create_burndown_page
		erb "Burndown of #{params['user']}/#{params['repo']}!"
	end
	def create_user_stories_page
		erb "User stories of #{params['user']}/#{params['repo']}!"
	end
end
