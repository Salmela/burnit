require 'sinatra'
require 'sinatra/base'

module User
	def run_user
		erb "User #{params['user']}!"
	end
end
