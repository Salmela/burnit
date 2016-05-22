require_relative 'github_api'
require_relative 'test.rb'

module Repo
	# this should be generated per milestone not by repo
	def create_repo_burndown_svg
		content_type("image/svg+xml")
	end

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
