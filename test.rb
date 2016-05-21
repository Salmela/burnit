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
	end

	def add_point(x, y)
		@array.push([x, y])
	end

	def print
		@array.each do |x|
			puts x[0].to_s + ", " + x[1].to_s
		end
	end

	private def exportPoints(svg)
		svg.addPath(@array, false)
	end

	def export
		svg = SvgBuilder.new("test.svg", 100, 80)
		svg.setFill("none")
		svg.setStroke("#73d216")
		svg.addRect(1, 1, 98, 78)

		svg.setStroke("#729fcf")
		exportPoints(svg)
		svg.close
	end
end

chart = Chart.new
chart.add_point(1, 2)
chart.add_point(8, 3)
chart.print
chart.export
