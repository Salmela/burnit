require "net/http"

class SvgBuilder
	def initialize(filename, w, h)
		@w = w
		@h = h
		@file = File.new(filename, "w")
		@file.puts "<svg>"
	end

	def addRect(x, y, w, h)
		@file.puts "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" height=\"#{h}\" />"
	end

	def close
		@file.puts "</svg>"
	end
end

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

	def export
		svg = SvgBuilder.new("test.svg", 100, 80)
		svg.addRect(1, 1, 98, 78)
		svg.close
	end
end

chart = Chart.new
chart.add_point(1, 2)
chart.add_point(8, 3)
chart.print
chart.export
