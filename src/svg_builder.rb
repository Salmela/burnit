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
