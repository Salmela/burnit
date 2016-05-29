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
	attr_accessor :text_anchor, :font_family, :font_size
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

	def fill=(color)
		@fill = color
	end

	def stroke=(color)
		@stroke = color
	end

	def stroke_width=(width)
		if width <= 0
			@stroke_width = nil
			return
		end
		@stroke_width = width
	end

	private def create_style_attrs
		return "stroke=\"#{@stroke}\" fill=\"#{@fill}\" " +
		       "stroke-width=\"#{@stroke_width}\""
	end

	private def create_font_attrs
		buf = "";
		buf += "text-anchor=\"#{text_anchor}\" " if text_anchor
		buf += "font-family=\"#{font_family}\" " if font_family
		buf += "font-size=\"#{font_size.to_i}\"" if font_size
		return buf
	end

	#TODO replace this with add_group method
	def open_group
		append "<g #{create_style_attrs} #{create_font_attrs}>"
	end

	def close_group
		append "</g>"
	end

	def add_text(x, y, text)
		append "<text x=\"#{x}\" y=\"#{y}\" "
		append "#{create_style_attrs} #{create_font_attrs}"
		append ">#{text}</text>"
	end

	def add_rect(x, y, w, h)
		append "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{w}\" "
		       "height=\"#{h}\" #{create_style_attrs} />"
	end

	def add_path(coords, connect_tail)
		append "<path d=\""
		append "M "

		coords.each do |coord|
			append "#{coord[0].to_s},#{coord[1].to_s} "
		end
		append "z" if connect_tail
		append "\" #{create_style_attrs} />\n"
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
