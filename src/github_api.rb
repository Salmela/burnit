require 'net/http'
require 'json'

class GithubApi
	@@instance = GithubApi.new
	attr_reader :user, :repo

	def initialize(user, repo)
		@user = user
		@repo = repo

		startSession
	end

	def startSession()
		@http = Net::HTTP.new("api.github.com", 443)
		@http.use_ssl = true
	end

	def load(uri, limit = 3)
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
