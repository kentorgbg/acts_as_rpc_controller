class ApplicationError

  acts_as_rpc_action do
    description    "Raises an application error with code 42"
    request_method :get
    returns        :dummy
  end


  def execute
  	raise AARPCC::Errors::ApplicationError.new(42, "Application error 42")
  end
end