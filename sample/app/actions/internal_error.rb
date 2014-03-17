class InternalError

	acts_as_rpc_action  do
		description "Throws an exception"
		request_method :get
		returns :dummy
	end

	def execute
		raise "Hell"
	end
end