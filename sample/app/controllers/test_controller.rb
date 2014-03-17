class TestController < ActionController::Metal

  acts_as_rpc_controller do
    action :echo_string,           EchoString
    action :echo_string_with_post, EchoStringWithPost
    action :echo_integer,          EchoInteger
    action :application_error,     ApplicationError
  end

end