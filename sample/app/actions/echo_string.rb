class EchoString

  acts_as_rpc_action do
    description    "Returns the given string"
    request_method :get
    parameter      :message
    returns        :message
  end


  def execute
    params[:message]
  end
end