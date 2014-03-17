class EchoStringWithPost

  acts_as_rpc_action do
    description    "Returns the given message"
    request_method :post
    parameter      :message
    returns        :message
  end

  def execute
    params[:message]
  end

end