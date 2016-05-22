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
require_relative 'test.rb'

class GithubIssue2
	attr_reader :tasks

	def initialize(data)
		@data = data
		@tasks = Array.new
		@parent_ids = Array.new
	end

	def name
		@data['title']
	end

	def id
		@data['number']
	end

	def url
		@data['html_url']
	end

	def body
		@data['body']
	end

	def state
		case @data['state']
		when 'open'
			'not started'
		when 'closed'
			'done'
		end
	end

	def owner
		raise "github_api_error" unless @data.key?('assignee')
		assignee = @data['assignee']
		return "none" unless assignee

		#TODO improve error handling
		raise "github_api_error" unless assignee.key?('login')
		assignee['login'].to_s
	end

	private def go_through_labels
		@labels_fetched = true
		@is_user_story = false
		labels = @data['labels']

		labels.each do |label|
			next unless label.key?('name')
			name = label['name'].to_s;
			matches = /(\d+)h/.match(name)

			if matches
				@size = matches[1]
			end

			reg = Regexp.new("user[ _-]story", Regexp::IGNORECASE)
			matches = reg.match(name)
			if matches
				@is_user_story = true
			end

			reg = Regexp.new("epic", Regexp::IGNORECASE)
			matches = reg.match(name)
			if matches
				@is_epic = true
			end
		end
	end

	protected def put_task(issue)
		@tasks.push(issue)
	end

	private def add_task(task_map, issue_map, parent_id)
		@parent_ids.push(parent_id)

		if issue_map.key?(parent_id)
			puts 'parent exists already'
			issue_map[parent_id].put_task(self)
			return
		end
		if task_map.key?(parent_id)
			puts 'parent has child list already'
			list = task_map[parent_id]
		else
			puts 'create task list for parent'
			list = Array.new
			task_map[parent_id] = list
		end
		list.push(self)
		puts "put myself to parent's task list (#{list.length})"
	end

	def update_task_map(task_map, issue_map)
		puts "task map size: " + task_map.size.to_s
		puts "size: " + @tasks.size.to_s

		puts "map: " + task_map.keys.to_s
		puts "has key " + task_map.key?(id).to_s
		@tasks = task_map[id] if task_map.key?(id)
		# use regexp substitution to go through all of it's matches
		return unless body

		str = body.gsub(/Task.{1,10}#(\d+)/i) { |match_str|
			parent = $~[1]
			puts "task of #{parent} found as #{id}"
			return '' if parent == self.id
			puts 'put task'
			add_task(task_map, issue_map, parent.to_i)
			''
		}
	end

	def size
		go_through_labels unless @labels_fetched
		return @size
	end

	def epic?
		go_through_labels unless @labels_fetched
		return @is_epic
	end

	def user_story?
		go_through_labels unless @labels_fetched
		return @is_user_story
	end
end

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
			issue = GithubIssue2.new(data)
			puts "issue ##{issue.id}"
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
		issues.each{|issue| puts "#{issue.id}; #{issue.tasks.length}"}
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
