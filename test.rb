require "net/http"

class Chart
	def initialize
		@array = Array.new
	end

	def add_point(x, y)
		@array.push([x, y])
	end

	def print
		@array.each do |x|
			puts x[0].to_s + ", " + x[1].to_s
		end
	end
end

chart = Chart.new
chart.add_point(1, 2)
chart.add_point(8, 3)
chart.print
