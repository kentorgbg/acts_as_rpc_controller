module AARPCC::ActionSupport

  #
  #
  #
  def self.included(action_class)
    action_class.class_eval do
      extend ClassMethods
    end
  end


  #
  #
  #
  module ClassMethods

    def acts_as_rpc_action(&block)
      decl = ActionDeclaration.new
      decl.instance_eval(&block)
      decl.apply_on(self)
    end
  end


  #
  #
  #
  class ActionDeclaration

    attr_reader :parameter_declarations

    def initialize
      @request_method         = :get
      @parameter_declarations = {}.with_indifferent_access
    end


    def description(text)
      @description = text
    end

    def get_description
      @description
    end

    
    def request_method(method)
      @request_method = method.to_s.strip.downcase.to_sym
    end


    def get_request_method
      @request_method
    end

    
    def parameter(name, options = {})
      @parameter_declarations[name] = ParameterDeclaration.new(name, options)
    end


    def returns(name, options = {})
      @returns = ParameterDeclaration.new(name, options)
    end

    def get_returns_declaration
      @returns
    end

    
    def apply_on(action_class)
      action_class.cattr_accessor :action_declaration
      action_class.action_declaration = self
      action_class.class_eval{ attr_accessor :params }
    end
  end


  #
  #
  #
  class ParameterDeclaration

    attr_reader :name

    def initialize(name, options = {})
      @name    = name
      @options = options.with_indifferent_access
    end

    def validator
      klass = @options[:validate_with] || AARPCC::Validators::String
      klass.new
    end
  end

end