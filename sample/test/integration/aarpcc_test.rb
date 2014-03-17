require_relative '../test_helper'

class AARPCCTest < ActionDispatch::IntegrationTest

	include AARPCC::IntegrationTestSupport


	test "echo string" do
		message = "The quick brown fox jumps over the lazy dog."
		result  = rpc :echo_string, message: message
		assert_equal message, result
	end


	test "echo integer" do
		number = 42
		result = rpc :echo_integer, number: number
		assert_equal number, result
	end


	test "wrong request method should give HTTP 405" do
		post "/test/echo_string", message: "test"
		assert_equal 405, response.status
	end


	test "missing parameter should give 400 Bad Request" do
		get "/test/echo_string", {}, 'Accept' => 'application/json'
		assert_equal 400, response.status
	end


	test "extra parameter should give 400 Bad Request" do
		get "/test/echo_string", {message: 'Test', extra: 'Extra'}, 'Accept'=>'application/json'
		assert_equal 400, response.status
	end


	test "wrong parameter type should give 400 Bad Request" do
		begin
			rpc :echo_integer, number: "foo"
			fail
		rescue AARPCC::IntegrationTestSupport::RPCError => e
			assert_equal 400, e.http_status_code
		end
	end


	test "malformed JSON should give 400 Bad Request" do
		get "/test/echo_string", {message: "test"}, 'Accept'=>'application/json' # Not JSON encoded
		assert_equal 400, response.status
	end


  test "internal error" do
    begin
      rpc :internal_error
      fail  
    rescue AARPCC::IntegrationTestSupport::RPCError => e
      assert_equal 500, e.http_status_code
    end
  end
end