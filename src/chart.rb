# Burnit is free software: you can redistribute it and/or modify
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

class Object
  def is_number?
    self.is_a?(Fixnum) || self.is_a?(Numeric) || self.is_a?(Float)
  end
end

class Chart
	def initialize(w)
		@data = Array.new
		@max_value = 0
		@width = w
	end

	def add_point(x, y)
		raise ArgumentError unless x.is_number?
		raise ArgumentError unless y.is_number?

		insert_at = @data.index{|p| p[0] > x}
		@data.insert(insert_at.to_i, [x.to_f, y.to_f])

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

	private def export_labels(svg, w, h)
		str = ""
		svg.stroke_width = 0
		svg.fill = "#010101"
		svg.stroke = "none"
		svg.text_anchor = "middle"
		svg.font_size = 11
		svg.font_family = "DejaVu Sans,Verdana,Geneva,sans-serif"
		svg.open_group
		# add style/font reset command to svg_builder
		svg.text_anchor = nil
		svg.font_size = nil
		svg.font_family = nil

		@width.to_i.times.each do |i|
			x = i * w_piece(w)
			y = h
			text = "mo"
			svg.add_text(x + w_piece(w) / 2, y - 11, text)
		end
		svg.close_group

		str += "</g>"
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
		export_labels(svg, 640, 480)
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

class Time
	def ceil(seconds)
		Time.at((self.to_f / seconds).ceil * seconds).utc
	end
	def floor(seconds)
		Time.at((self.to_f / seconds).floor * seconds).utc
	end
end

class ChartByTime < Chart
	attr_accessor :stair_case

	def initialize(start_time, end_time)
		raise ArgumentError unless start_time.is_a?(Time)
		raise ArgumentError unless end_time.is_a?(Time)

		@start_time = start_time
		@end_time = end_time

		compute_roughness
		@start_time = @start_time.floor(@roughness)
		@end_time = @end_time.ceil(@roughness)
		super((@end_time - @start_time).to_f / @roughness)
	end

	private def compute_roughness()
		# hard coded as days
		@roughness = 60 * 60 * 24
	end

	def add_data(time, data)
		raise ArgumentError unless time.is_a?(Time)
		raise ArgumentError unless data.is_number?

		x = ((time - @start_time).to_f /  @roughness)

		#TODO move this to Chart class
		if @stair_case && @prev_value
			add_point(x, @prev_value)
		end
		add_point(x.to_f, data.to_f)
		@prev_value = data.to_f
		return
	end
end
