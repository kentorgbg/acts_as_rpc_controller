#!/usr/bin/env ruby
require_relative '../config/environment'
require 'pp'

def main(argv)

  service_client_code  = `curl -s localhost:3000/documentation/service_client?class_name=ServiceClient`
  eval(service_client_code)

  decoder     = lambda{ |json|   ActiveSupport::JSON::decode(json) }
  encoder     = lambda{ |object| ActiveSupport::JSON::encode(object) }

  sc = ServiceClient.new('localhost:3000', decoder, encoder)

  pp sc.echo_integer(number: 42)
  pp sc.echo_string_with_post(message: 'Hello World!')
  begin
    sc.application_error
  rescue HttpClientError => e
    pp e.status
    pp e.app_error_code
    pp e.message
  end
end

main(ARGV)