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

require "sinatra/base"

class Shield
	def initialize(text1, text2)
		@texts = Array.new(2)
		@texts[0] = text1
		@texts[1] = text2

		@widths = Array.new(2)
		@widths[0] = 65
		@widths[1] = 35
	end

	def locals
		{:texts => @texts,
		:widths => @widths,
		:colorA => "#555",
		:colorB => "#e05d44"}
	end

	def file
		# support other styles
		:shield
	end
end
