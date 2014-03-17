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
    uri       = URI("http://#{@host}#{path}")
    response  = Net::HTTP.post_form(uri, json_encode_values(params))
    handle_response(response)
  end


  def get(path, params)
    qstring  = encode_params(params)
    uri      = URI("http://#{@host}#{path}?#{qstring}")
    response = Net::HTTP.get_response(uri)
    handle_response(response)
  end


  def json_encode_values(params)
    {}.tap do |h|
      params.each{ |k, v| h[k] = @encoder.call(v) }
    end
  end


  def encode_params(params)
    json_encode_values(params).map{ |k, v| "#{k}=#{URI.encode_www_form_component(v)}"}.join("&")
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