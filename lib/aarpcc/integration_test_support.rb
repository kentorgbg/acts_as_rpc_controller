module AARPCC::IntegrationTestSupport

  def rpc(action_name, params = {})
    TestInvoker.new(action_name, self).invoke(params.with_indifferent_access)
  end


  class RPCError < StandardError

    attr_reader :http_status_code, :application_error_code

    def initialize(http_status_code, application_error_code, message)
      @http_status_code       = http_status_code
      @application_error_code = application_error_code
      super(message)
    end
  end


  class TestInvoker

    def initialize(action_name, test_instance)
      @action_name   = action_name
      @test_instance = test_instance
    end


    def invoke(params)
      controller_class, action_declaration = action_declarations[@action_name]
      method         = action_declaration.get_request_method
      path           = path_for(controller_class)
      encoded_params = {}.tap{ |ep| params.each{ |k, v| ep[k] = v.to_json }} 

      pp encoded_params


      @test_instance.send(method, path, encoded_params)

      if ((status = @test_instance.response.status) == 200)
        raw_result = @test_instance.response.body
        ActiveSupport::JSON::decode(raw_result)
      else
        app_error = @test_instance.response.headers['X-Application-Error-Code'].to_i
        message   = @test_instance.response.body
        raise RPCError.new(status, app_error, message)
      end
    end


    def action_declarations
      @action_declarations ||= {}.with_indifferent_access.tap do |decls|
        rpc_controller_classes.each do |controller_class|
          controller_class.aarpcc_declaration.action_classes.each do |action_name, action_class|
            decls[action_name] = [controller_class, action_class.aarpcc_declaration]
          end
        end
      end
    end


    def rpc_controller_classes
      ActionController::Metal.subclasses.select{ |c| c.methods.include? :aarpcc_declaration }
    end


    def path_for(controller_class)
      controller_path = controller_class.to_s.split("::").map{ |p| p.underscore }.join("/").sub(/_controller$/, '')
      "/#{controller_path}/#{@action_name}"
    end

  end
end