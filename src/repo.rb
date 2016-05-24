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

class GithubMilestone
	attr_reader :repository

	def initialize(repo, data)
		@repository = repo
		@data = data
	end

	def name; @data['title'] end
	def start_time; Time.iso8601(@data['created_at']) end
	def end_time; Time.iso8601(@data['due_on']) end
end

class GithubRepository
	@issue_map = nil
	@task_map = nil
	@issues = nil
	@milestones = nil

	attr_reader :issues

	def initialize(user, repo)
		@user = user
		@name = repo
		@issues = fetch_issues(GithubApi.get_default, user, repo)
		fetch_milestones(GithubApi.get_default, user, repo)
	end

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

		@task_map = nil

		return issues
	end

	def fetch_milestones(github_api, user, repo)
		@milestones = Array.new

		uri = URI("https://api.github.com/repos/#{user}/#{repo}/milestones?state=all")
		json_milestones = github_api.load(uri)
		return Array.new unless json_milestones

		@milestones = Array.new
		json_milestones.each do |data|
			milestone = GithubMilestone.new(self, data)
			@milestones.push(milestone)
		end
	end
end

module Repo
	@@repos = nil

	def init_repo
		@user = params['user']
		@repo = params['repo']
		@repository = load_repo(@user, @repo)
	end

	def load_repo(user, repo)
		id = user + "/" + repo
		@@repos = Hash.new unless @@repos
		return @@repos[id] if @@repos.key?(id)

		repo = GithubRepository.new(user, repo)
		@@repos[id] = repo

		return repo
	end

	# this should be generated per milestone not by repo
	def create_repo_burndown_svg
		init_repo

		chart = Chart.new
		chart.add_point(0, 8)
		chart.add_point(0.5, 7)
		chart.add_point(1, 3)
		chart.add_point(2, 4)
		chart.add_point(3, 1)
		chart.add_point(4, 0)

		return chart.svg_buffer
	end

	def create_burndown_page
		init_repo
		erb :chart_view, :locals => {
			:links => true}
	end

	def create_user_stories_page
		init_repo
		user_stories = @repository.issues.select{|issue| \
			issue.user_story?}
		user_stories.sort{|story1, story2| \
			story1.name <=> story2.name}
		erb :stories_view, :locals => {
			:user_stories => user_stories,
			:links => true}
	end

	def create_tasks_page
		init_repo
		erb :tasks_view, :locals => {
			:issues => @repository.issues,
			:links => true}
	end
end
