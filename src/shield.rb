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
