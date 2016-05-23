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
require 'net/http'
require 'json'
require 'date'

class SvgBuilder
	def initialize(w, h)
		@w = w
		@h = h
		@buffer = ''
		@stroke_width = 1
		append "<svg xmlns=\"http://www.w3.org/2000/svg\" " +
			"width=\"#{w}\" height=\"#{h}\">"
	end

	private def append(text)
		@buffer += text
	end

	#TODO remove camelCase from method names and use ruby style
	def setFill(color)
		@fill = color
	end

	def setStroke(color)
		@stroke = color
	end

	def stroke_width=(width)
		raise "Width must be positive" if width <= 0
		@stroke_width = width
	end

	private def createStyleAttrs
		return "stroke=\"#{@stroke}\" fill=\"#{@fill}\" " +
		       "stroke-width=\"#{@stroke_width}\""
	end

	def addRect(x, y, w, h)
		append "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" height=\"#{h}\" #{createStyleAttrs} />"
	end

	def addPath(coords, connect_tail)
		append "<path d=\""
		append "M "

		coords.each do |coord|
			append "#{coord[0].to_s},#{coord[1].to_s} "
		end
		append "z" if connect_tail
		append "\" #{createStyleAttrs} />\n"
	end

	def close
		append "</svg>"
	end

	def save_to_file(filename)
		File.open(filename, 'w') do |f|
			f.write(@buffer)
		end
	end

	def to_s
		@buffer
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

	def generateSvg
		svg = SvgBuilder.new(640, 480)
		svg.setFill("none")

		svg.setStroke("#d8d8d8")
		exportFrame(svg, 640, 480)

		svg.setStroke("#729fcf")
		svg.stroke_width = 4
		exportPoints(svg, 640, 480)
		svg.close

		return svg
	end

	def svg_buffer
		generateSvg.to_s
	end

	def export
		generateSvg.save_to_file("test.svg")
	end
end

#TODO the rate-limit is user specific as far as know
$wait_until = nil

#api = GithubApi.new("octocat", "hello-world")
#fetcher = GithubIssueFetcher.new(api)

#chart = Chart.new
#chart.add_point(0, 8)
#chart.add_point(0.5, 7)
#chart.add_point(1, 3)
#chart.add_point(2, 4)
#chart.add_point(3, 1)
#chart.add_point(4, 0)
#chart.export
