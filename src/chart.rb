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
require_relative 'svg_builder'

require 'net/http'
require 'json'
require 'date'

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

	private def export_points(svg, w, h)
		points = Array.new

		@data.each_with_index do |point|
			points.push([point[0] * w_piece(w),
			             h - point[1] * h_piece(h)])
		end
		svg.add_path(points, false)
	end

	private def export_frame(svg, w, h)
		points = Array.new()

		(1..(@max_value - 1)).each do |i|
			y = h_piece(h) * i
			points[0] = [1, y]
			points[1] = [w - 1, y]
			svg.add_path(points, false)
		end

		(1..(@width - 1)).each do |i|
			x = w_piece(w) * i
			points[0] = [x, 1]
			points[1] = [x, h - 1]
			svg.add_path(points, false)
		end
	end

	def generate_svg
		svg = SvgBuilder.new(640, 480)
		svg.fill = "none"

		svg.stroke = "#d8d8d8"
		export_frame(svg, 640, 480)

		svg.stroke = "#729fcf"
		svg.stroke_width = 4
		export_points(svg, 640, 480)
		svg.close

		return svg
	end

	def svg_buffer
		generate_svg.to_s
	end

	def export
		generateSvg.save_to_file("test.svg")
	end
end

class ChartByTime < Chart
	def intialize(start_time, end_time)
	end
end
