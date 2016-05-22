require_relative 'github_api'
require_relative 'test.rb'

class GithubIssue2
	def initialize(data)
		@data = data
	end

	def name
		@data['title']
	end

	def url
		@data['html_url']
	end

	private def go_through_labels
		@labels_fetched = true
		@is_user_story = false
		labels = @data['labels']

		labels.each do |label|
			next unless label.key?('name')
			name = label['name'].to_s;
			matches = /(\d)h/.match(name)
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
	def fetch_issues(github_api, user, repo)
		issues = Array.new
		uri = URI("https://api.github.com/repos/#{user}/#{repo}/issues?state=all")
		json_issues = github_api.load(uri)

		@issues = Array.new
		json_issues.each do |data|
			issues.push(GithubIssue2.new(data))
		end

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
		tasks = fetch_issues(GithubApi.get_default, params['user'], params['repo'])
		erb :repo_view, :locals => {
			:tasks => tasks,
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
