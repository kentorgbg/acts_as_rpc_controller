class DocumentationController < ActionController::Metal

  acts_as_rpc_documentation do
    rpc_controller TestController
  end
end