module AARPCC::Errors

  class Base < StandardError

    attr_reader :http_status_code, :application_error_code

    def initialize(http_status_code, application_error_code, message)
      @http_status_code       = http_status_code
      @application_error_code = application_error_code
      super(message)
    end
  end


  class BadRequest < Base
    def initialize(message)
      super(400, 0, message)
    end
  end


  class MethodNotAllowed < Base
    def initialize
      super(405, 0, "Method Not Allowed")
    end
  end


  class NotAcceptable < Base
    def initialize
      super(406, 0, "Unsupported content type")
    end
  end

  class ApplicationError < Base
    def initialize(application_error_code, message)
      super(499, application_error_code, message)
    end
  end
end