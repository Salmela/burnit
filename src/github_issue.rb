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

class GithubIssue
	attr_reader :tasks

	def initialize(data)
		@data = data
		@tasks = Array.new
		@parent_ids = Array.new
	end

	def name; @data['title'] end

	def id; @data['number'] end

	def url; @data['html_url'] end

	def body; @data['body'] end

	def closed_at
		return nil unless @data['closed_at']
		Time.iso8601(@data['closed_at'])
	end

	def in_milestone?(milestone, depth = 3)
		res = false
		return res if depth == 0
		@parent_ids.each do |parent|
			res = in_milestone?(milestone, depth - 1)
			#puts ' ' * (4 - depth) + "parent ", res
		end

		obj = @data['milestone']
		return res unless obj || res

		obj['id'] == milestone.id
	end

	#TODO check the labels
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
			issue_map[parent_id].put_task(self)
			return
		end
		if task_map.key?(parent_id)
			list = task_map[parent_id]
		else
			list = Array.new
			task_map[parent_id] = list
		end
		list.push(self)
	end

	def update_task_map(task_map, issue_map)
		@tasks = task_map[id] if task_map.key?(id)
		# use regexp substitution to go through all of it's matches
		return unless body

		str = body.gsub(/Task.{1,10}#(\d+)/i) { |match_str|
			parent = $~[1]
			return '' if parent == self.id
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
