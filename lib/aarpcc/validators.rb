module AARPCC::Validators

  class Base
    def raise_type_error(name, object, expected, message = nil)
      message ||= "Type error: '#{name}' is of type #{object.class}, expected #{expected}"
      raise AARPCC::Errors::BadRequest.new(message)
    end
  end


  class Integer < Base

    def validate(name, object)
      return if object.kind_of? ::Integer
      raise_type_error(name, object, ::Integer)
    end
  end


  class String < Base

    def validate(name, object)
      return if object.kind_of? ::String
      raise_type_error(name, object, ::String)
    end
  end
end