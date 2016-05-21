require "net/http"

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
		@array = Array.new
		@max_value = 0
		@width = 0
	end

	def add_point(x, y)
		insert_at = @array.index{|p| p[0] > x}
		@array.insert(insert_at.to_i, [x, y])

		@width = x if x > @width
		@max_value = y if y > @max_value
	end

	def print
		@array.each do |point|
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

		@array.each_with_index do |point|
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

chart = Chart.new
chart.add_point(0, 8)
chart.add_point(0.5, 7)
chart.add_point(1, 3)
chart.add_point(2, 4)
chart.add_point(3, 1)
chart.add_point(4, 0)
chart.export
