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

require_relative 'github_api'
require_relative 'github_issue'
require_relative 'test'

module Repo
	@issue_map = nil
	@task_map = nil

	def fetch_issues(github_api, user, repo)
		@issue_map = Hash.new unless @issue_map
		@task_map = Hash.new unless @task_map

		issues = Array.new
		uri = URI("https://api.github.com/repos/#{user}/#{repo}/issues?state=all")
		json_issues = github_api.load(uri)
		return Array.new unless json_issues

		@issues = Array.new
		json_issues.each do |data|
			issue = GithubIssue.new(data)
			issue.update_task_map(@task_map, @issue_map)
			@issue_map[issue.id] = issue
			issues.push(issue)
		end

		puts " issue map: " + @issue_map.keys.to_s
		puts " task map: " + @task_map.keys.to_s
		@task_map = nil

		return issues
	end

	# this should be generated per milestone not by repo
	def create_repo_burndown_svg
		chart = Chart.new
		chart.add_point(0, 8)
		chart.add_point(0.5, 7)
		chart.add_point(1, 3)
		chart.add_point(2, 4)
		chart.add_point(3, 1)
		chart.add_point(4, 0)

		return chart.svg_buffer
	end

	def create_repo_page
		issues = fetch_issues(GithubApi.get_default, params['user'], params['repo'])
		user_stories = issues.select{|issue| issue.user_story?}
		user_stories.sort{|story1, story2| \
			story1.name <=> story2.name}

		erb :repo_view, :locals => {
			:user_stories => user_stories,
			:issues => issues,
			:user => params['user'],
			:repo => params['repo']}
	end
	def create_burndown_page
		erb "Burndown of #{params['user']}/#{params['repo']}!"
	end
	def create_user_stories_page
		erb "User stories of #{params['user']}/#{params['repo']}!"
	end
end
