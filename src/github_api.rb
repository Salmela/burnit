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

require 'net/http'
require 'json'
require 'uri'

#TODO the rate-limit is user specific as far as I know
$wait_until = nil

class GithubApi
	@@instance = nil
	attr_reader :user, :repo

	def initialize(user, repo)
		@user = user
		@repo = repo

		startSession
	end

	def GithubApi.get_default
		if !@@instance
			@@instance = GithubApi.new(nil, nil)
		end
		@@instance
	end

	def startSession()
		@http = Net::HTTP.new("api.github.com", 443)
		@http.use_ssl = true
	end

	def load(uri, limit = 3)
		raise ArgumentError unless uri.is_a?(URI)
		raise ArgumentError, 'Too many HTTP redirects' if limit == 0
		raise 'We are rate limited' if $wait_until != nil

		req = Net::HTTP::Get.new(uri.request_uri)
		req["User-Agent"] = "sprint-burndown-app-salmela"
		response = @http.request(req)

		puts "limit: " + response["X-RateLimit-Limit"]
		puts "remaining: " + response["X-RateLimit-Remaining"]
		puts "reset: " + response["X-RateLimit-Reset"]

		case response
		when Net::HTTPSuccess
			return JSON.parse(response.body)
		when Net::HTTPRedirection
			return load(URI(response['location']), limit - 1)
		#TODO log the messages here
		when Net::HTTPForbidden
			if response["X-RateLimit-Remaining"].to_i == 0
				reset_time = response["X-RateLimit-Reset"]
				$wait_until = Time.at(reset_time).to_datetime
				raise 'We are rate limited'
			else
				raise 'Http request was forbidden'
			end
		end
	end
end
