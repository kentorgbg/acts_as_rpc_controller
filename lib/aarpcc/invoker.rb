class AARPCC::Invoker

  def initialize(controller_instance, action_class)
    @controller_instance = controller_instance
    @action_class        = action_class
  end


  def invoke
    AARPCC::Logger.new(@controller_instance).log{ invoke_wo_logging }
  end


  def invoke_wo_logging
    validate_request_method
    validate_accept_header
    validate_declared_params_given
    validate_given_params_declared
    validate_param_types
    assign_params
    result = action_instance.execute
    renderer.render_result(result)
  rescue AARPCC::Errors::Base => e
    renderer.render_aarpcc_error(e)
  rescue Exception => e
    renderer.render_internal_error(e)
    raise e
  end

  
  def validate_request_method
    declared_request_method = action_declaration.get_request_method
    request_method          = request.method.to_s.strip.downcase.to_sym
    raise AARPCC::Errors::MethodNotAllowed.new unless request_method == declared_request_method
  end


  def validate_accept_header
    content_types = (request.headers["Accept"] || "").split(",").map(&:strip)
    return if content_types.any?{ |ct| renderer.supported_content_type? ct }
    raise AARPCC::Errors::NotAcceptable.new
  end


  def validate_declared_params_given
    action_declaration.parameter_declarations.each do |name, decl|
      next if request.params.has_key? name
      raise AARPCC::Errors::BadRequest.new("Missing parameter '#{name}'")
    end
  end


  def validate_given_params_declared
    request.params.each do |name, value|
      next if name.to_sym == :controller
      next if name.to_sym == :action
      next if action_declaration.parameter_declarations.has_key? name
      raise AARPCC::Errors::BadRequest.new("Undeclared parameter '#{name}'")
    end
  end


  def validate_param_types
    decoded_params.each do |name, value|
      pdecl = action_declaration.parameter_declarations[name]
      pdecl.validator.new(name, value).validate
    end
  end


  def assign_params
    action_instance.params = decoded_params
  end


  def request
    @controller_instance.request
  end


  def action_instance
    @action_instance ||= @action_class.new
  end


  def action_declaration
    @action_class.aarpcc_declaration
  end


  def renderer
    @renderer ||= begin
      renderer_class = @controller_instance.class.aarpcc_declaration.renderer_class
      renderer_class.new(@controller_instance)
    end
  end


  def decoded_params
    @decoded_params ||= {}.with_indifferent_access.tap do |result|
      request.params.each do |name, value|
        next if name.to_sym == :controller
        next if name.to_sym == :action
        result[name] = decode_param(name, value)
      end
    end
  end


  def decode_param(name, value)
    ActiveSupport::JSON::decode(value)
  rescue MultiJson::ParseError => e
    raise AARPCC::Errors::BadRequest.new("'#{name}': #{e.message}")
  end
  
end