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
      decl = ControllerDeclaration.new
      decl.instance_eval(&block)
      decl.apply_on(self)
    end
  end


  #
  #
  #
  module InstanceMethods
    def aarpcc_invoke(action_class)
      result = Invoker.new(action_class).invoke(request, response)
      self.response_body = result.to_json
      self.status = 200
    rescue AARPCC::Errors::Base => e
      self.response_body                       = e.message
      self.status                              = e.http_status_code
      self.headers["X-Application-Error-Code"] = e.application_error_code 
    end
  end


  #
  #
  #
  class ControllerDeclaration

    attr_reader :action_classes

    def initialize
      @action_classes = {}.with_indifferent_access
    end

    def action(name, action_class)
      @action_classes[name] = action_class
    end

    def set_parameter_parser(parser_class)
    end

    def set_result_renderer(renderer_class)
    end

    def set_error_renderer(renderer_class)
    end

    def apply_on(controller_class)
      controller_class.cattr_accessor :aarpcc_declaration
      controller_class.aarpcc_declaration = self
      @action_classes.each do |name, klass|
        define_rails_action(controller_class, name, klass)
      end
    end

    def define_rails_action(controller_class, action_name, action_class)
      controller_class.class_eval do
        define_method(action_name){ aarpcc_invoke(action_class) }
      end
    end
  end


  #
  #
  #
  class Invoker

    def initialize(action_class)
      @action_class = action_class
    end

    def invoke(request, response)
      action = @action_class.new
      validate_request_method(request)
      validate_declared_params_given(request)
      validate_given_params_declared(request)
      decoded_params = decode_params(request)
      validate_param_types(decoded_params)
      assign_params(action, decoded_params)
      action.execute
    end

    def assign_params(action, decoded_params)
      action.params = {}.with_indifferent_access
      decoded_params.each do |name, value|
        action.params[name] = value
      end
    end

    def validate_request_method(request)
      declared_request_method = action_declaration.get_request_method
      request_method          = request.method.to_s.strip.downcase.to_sym
      raise AARPCC::Errors::MethodNotAllowed.new unless request_method == declared_request_method
    end

    def validate_declared_params_given(request)
      action_declaration.parameter_declarations.each do |name, decl|
        next if request.params.has_key? name
        raise AARPCC::Errors::BadRequest.new("Missing parameter '#{name}'")
      end
    end

    def validate_given_params_declared(request)
      request.params.each do |name, value|
        next if name.to_sym == :controller
        next if name.to_sym == :action
        next if action_declaration.parameter_declarations.has_key? name
        raise AARPCC::Errors::BadRequest.new("Undeclared parameter '#{name}'")
      end
    end

    def decode_params(request)
      {}.tap do |result|
        request.params.each do |name, value|
          next if name.to_sym == :controller
          next if name.to_sym == :action
          result[name] = ActiveSupport::JSON::decode(value)
        end
      end
    end

    def validate_param_types(decoded_params)
      decoded_params.each do |name, value|
        pdecl = action_declaration.parameter_declarations[name]
        pdecl.validator.validate(name, value)
      end
    end


    def action_declaration
      @action_class.action_declaration
    end
  end

end