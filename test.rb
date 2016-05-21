require "net/http"
require "json"
require "date"

class SvgBuilder
	def initialize(filename, w, h)
		@w = w
		@h = h
		@file = File.new(filename, "w")
		@file.puts "<svg>"
	end

	def setFill(color)
		@fill = color
	end

	def setStroke(color)
		@stroke = color
	end

	private def createStyleAttrs
		return "stroke=\"#{@stroke}\" fill=\"#{@fill}\""
	end

	def addRect(x, y, w, h)
		@file.puts "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" height=\"#{h}\" #{createStyleAttrs} />"
	end

	def addPath(coords, connect_tail)
		@file.print "<path d=\""
		@file.print "M "
		coords.each do |coord|
			@file.print coord[0].to_s + "," + coord[1].to_s + " "
		end
		@file.print "z" if connect_tail
		@file.print "\" #{createStyleAttrs} />\n"
	end

	def close
		@file.puts "</svg>"
	end
end

class Chart
	def initialize
		@data = Array.new
		@max_value = 0
		@width = 0
	end

	def add_point(x, y)
		insert_at = @data.index{|p| p[0] > x}
		@data.insert(insert_at.to_i, [x, y])

		@width = x if x > @width
		@max_value = y if y > @max_value
	end

	def print
		@data.each do |point|
			puts point[0].to_s + ", " + point[1].to_s
		end
	end

	private def w_piece(w)
		w / @width.to_f
	end

	private def h_piece(h)
		h / @max_value.to_f;
	end

	private def exportPoints(svg, w, h)
		points = Array.new

		@data.each_with_index do |point|
			points.push([point[0] * w_piece(w),
			             h - point[1] * h_piece(h)])
		end
		svg.addPath(points, false)
	end

	private def exportFrame(svg, w, h)
		points = Array.new()

		(1..(@max_value - 1)).each do |i|
			y = h_piece(h) * i
			points[0] = [1, y]
			points[1] = [w - 1, y]
			svg.addPath(points, false)
		end

		(1..(@width - 1)).each do |i|
			x = w_piece(w) * i
			points[0] = [x, 1]
			points[1] = [x, h - 1]
			svg.addPath(points, false)
		end
	end

	def export
		svg = SvgBuilder.new("test.svg", 100, 80)
		svg.setFill("none")

		svg.setStroke("#d8d8d8")
		exportFrame(svg, 98, 78)

		svg.setStroke("#729fcf")
		exportPoints(svg, 98, 78)
		svg.close
	end
end

#TODO the rate-limit is user specific as far as know
$wait_until = nil

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

class GithubIssueFetcher
	def initialize(github_api)
		uri = URI("https://api.github.com/repos/#{github_api.user}/#{github_api.repo}/issues")
		issues = github_api.load(uri)
		puts "body: " + issues.to_s
	end

end

api = GithubApi.new("octocat", "hello-world")
fetcher = GithubIssueFetcher.new(api)

chart = Chart.new
chart.add_point(0, 8)
chart.add_point(0.5, 7)
chart.add_point(1, 3)
chart.add_point(2, 4)
chart.add_point(3, 1)
chart.add_point(4, 0)
chart.export
