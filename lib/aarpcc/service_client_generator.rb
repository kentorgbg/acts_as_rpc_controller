class AARPCC::ServiceClientGenerator

  def initialize(documentation_declaration, params = {})
    @documentation_declaration = documentation_declaration
    @params                    = params
  end

  def generate
    class_name     = @params[:class_name] || 'ServiceClient'
    service_client = TEMPLATE.sub('___CLASS_NAME___', class_name)
    service_client = service_client.sub('___SERVICE_METHODS___', service_methods)
  end

  def service_methods
    io = StringIO.new
    @documentation_declaration.controller_classes.each{ |cc| process_controller_class(cc, io) }
    io.string
  end

  def process_controller_class(controller_class, io)
    decl = controller_class.aarpcc_declaration
    decl.action_classes.each do |name, action_class|
      io << "\n\n" << process_action(controller_class, name, action_class.aarpcc_declaration)
    end
  end

  def process_action(controller_class, name, action_declaration)
    controller_path = controller_class.to_s.sub(/Controller$/, '').to_s.split("::").map{ |s| s.underscore }.join("/")
    path            = "/#{controller_path}/#{name}"
    request_method  = action_declaration.get_request_method
    code            = <<-RUBY
      def #{name}(params = {}); #{request_method}('#{path}', params); end
    RUBY
    code.split("\n").map{ |l| l.sub(/^\s{4}/, '') }.join("\n")
  end


  #
  #
  #


  TEMPLATE = <<-RUBY

#
# This file is generated, do not edit!
#

unless defined? HttpClientError

  class HttpClientError < StandardError

    attr_reader :status, :app_error_code

    def initialize(status, app_error_code, message)
      @status, @app_error_code = status, app_error_code
      super(message)
    end
  end
end


class ___CLASS_NAME___

  attr_accessor :host, :decoder, :encoder

  def initialize(host, decoder, encoder)
    @host    = host
    @decoder = decoder
    @encoder = encoder
  end
  ___SERVICE_METHODS___


  private


  def post(path, params)
    uri       = URI("http://\#{@host}\#{path}")
    response  = Net::HTTP.post_form(uri, json_encode_values(params))
    handle_response(response)
  end


  def get(path, params)
    qstring  = encode_params(params)
    uri      = URI("http://\#{@host}\#{path}?\#{qstring}")
    response = Net::HTTP.get_response(uri)
    handle_response(response)
  end


  def json_encode_values(params)
    {}.tap do |h|
      params.each{ |k, v| h[k] = @encoder.call(v) }
    end
  end


  def encode_params(params)
    json_encode_values(params).map{ |k, v| "\#{k}=\#{URI.encode_www_form_component(v)}"}.join("&")
  end


  def handle_response(response)
    if response.is_a? Net::HTTPSuccess
      @decoder.call(response.body)
    else
      status    = response.code.to_i
      app_error = response['X-Application-Error-Code'].to_i
      message   = response.body
      raise HttpClientError.new(status, app_error, message) 
    end
  end
end

  RUBY

end