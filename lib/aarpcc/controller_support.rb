module AARPCC::ControllerSupport

  #
  #
  #
  def self.included(controller_class)
    controller_class.class_eval do
      extend  ClassMethods
      include InstanceMethods
    end
  end


  #
  #
  #
  module ClassMethods

    def acts_as_rpc_controller(&block)
      decl = AARPCC::ControllerDeclaration.new
      decl.instance_eval(&block)
      decl.apply_on(self)
    end
  end


  #
  #
  #
  module InstanceMethods
    def aarpcc_invoke(action_class)
      result = AARPCC::Invoker.new(action_class).invoke(request, response)
      self.response_body = result.to_json
    rescue AARPCC::Errors::Base => e
      self.response_body                       = e.message
      self.status                              = e.http_status_code
      self.headers["X-Application-Error-Code"] = e.application_error_code.to_s
    end
  end

end