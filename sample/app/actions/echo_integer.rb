class EchoInteger

  acts_as_rpc_action do
    description "Returns the given number"
    request_method :get
    parameter      :number, validate_with: AARPCC::Types::Integer
    returns        :number
  end

  def execute
    params[:number]
  end
end