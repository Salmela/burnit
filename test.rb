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
	end

	def add_point(x, y)
		@array[x] = y
		@max_value = y if y > @max_value
	end

	def print
		@array.each_with_index do |value, i|
			puts i.to_s + ", " + @value.to_s
		end
	end

	private def exportPoints(svg, w, h)
		points = Array.new
		piece = w / (@array.length - 1).to_f
		h_piece = h / @max_value.to_f;

		@array.each_with_index do |value, i|
			points.push([i * piece, h - value * h_piece])
		end
		svg.addPath(points, false)
	end

	def export
		svg = SvgBuilder.new("test.svg", 100, 80)
		svg.setFill("none")
		svg.setStroke("#73d216")
		svg.addRect(1, 1, 98, 78)

		svg.setStroke("#729fcf")
		exportPoints(svg, 98, 78)
		svg.close
	end
end

chart = Chart.new
chart.add_point(0, 8)
chart.add_point(1, 3)
chart.add_point(2, 4)
chart.add_point(3, 1)
chart.print
chart.export
