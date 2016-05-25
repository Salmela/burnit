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
require_relative 'chart'

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

	attr_reader :issues, :milestones

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
		return if @repository.milestones.length == 0

		milestone = @repository.milestones[0]

		tasks = @repository.issues.select{|issue| \
			issue.closed_at && issue.size}
		sum = 0
		@repository.issues.each{|issue| \
			next unless !issue.closed_at && issue.size
			sum += issue.size.to_f
		}
		tasks.sort{|task1, task2| \
			task1.closed_at <=> task2.closed_at}

		chart = ChartByTime.new(milestone.start_time,
		                        milestone.end_time)

		tasks.each{|task| sum += task.size.to_f}

		chart.add_data(milestone.start_time, sum)
		puts "sum: " + sum.to_s
		tasks.each do |task|
			sum -= task.size.to_f
			puts "task " + sum.to_s
			chart.add_data(task.closed_at, sum)
		end

		return chart.svg_buffer
	end

	def create_burndown_page
		init_repo
		if @repository.milestones.length > 0
			milestone = @repository.milestones[0]
		end
		erb :chart_view, :locals => {
			:links => true,
			:milestone => milestone}
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
