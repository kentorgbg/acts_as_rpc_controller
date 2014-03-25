module AARPCC::Types


  class Base

    attr_reader :name, :value

    class_attribute :after_filters

    def self.after_filter(symbol)
      self.after_filters = (self.after_filters || []) + [symbol]
    end

    def initialize(name, value, base_type)
      @name, @value, @base_type = name, value, base_type
    end

    def validate
      validate_base_type
      perform_custom_validation
      run_after_filters
    end

    def validate_base_type
      return if @value.kind_of? @base_type
      base_type   = @base_type.to_s.underscore
      actual_type = @value.to_s.split("::")[-1].underscore
      type_error("#{@name}: expected #{base_type}, got #{actual_type}")
    end

    def perform_custom_validation
      raise "Not implemented"
    end

    def run_after_filters
      return if self.class.after_filters.blank?
      self.class.after_filters.each{ |f| run_after_filter(f) }
    end

    def run_after_filter(symbol)
      return if self.send(symbol)
      type_error("#{@name}: after_filter '#{symbol}' failed")
    end

    def type_error(message)
      raise AARPCC::Errors::BadRequest.new(message)
    end

  end


  class String < Base

    class_attribute :pattern_declaration

    def self.pattern(regexp)
      self.pattern_declaration = regexp
    end

    def initialize(name, value)
      super(name, value, ::String)
    end

    def perform_custom_validation
      regexp = self.class.pattern_declaration
      return if regexp.blank? || self.value =~ regexp
      type_error("#{self.name}: '#{value}' does not match #{regexp}")
    end
  end


  class Boolean < Base

    def initialize(name, value)
      super(name, value, nil)
    end

    def validate_base_type
      return if self.value.kind_of?(TrueClass) || self.value.kind_of?(FalseClass)
      actual_type = @value.class.to_s.split("::")[-1].underscore
      type_error("#{self.name}: expected boolean, got #{actual_type}")
    end

    def perform_custom_validation
    end
  end


  class Integer < Base

    def initialize(name, value)
      super(name, value, ::Integer)
    end

    def perform_custom_validation
    end
  end


  class Map < Base

    class_attribute :element_declarations

    def self.element(name, options = {})
      declaration = ElementDeclaration.new(name, options)
      self.element_declarations = (self.element_declarations || {}).merge(name => declaration).with_indifferent_access
    end

    def initialize(name, value)
      super(name, value, ::Hash)
    end

    def perform_custom_validation
      validate_declared_elements_given
      validate_gived_elements_declared
      validate_elements
    end

    def validate_declared_elements_given
      return if self.class.element_declarations.blank?
      self.class.element_declarations.each do |element_name, element_declaration|
        next if self.value.has_key? element_name
        next if element_declaration.optional?
        type_error("#{self.name}: missing element '#{element_name}'")
      end
    end

    def validate_gived_elements_declared
      self.value.each do |element_key, element_value|
        element_declaration = self.class.element_declarations[element_key]
        next unless element_declaration.nil?
        type_error("#{self.name}: unknown element '#{element_key}'")
      end
    end

    def validate_elements
      self.value.each{ |key, value| validate_element(key, value) }
    end

    def validate_element(key, element_value)
      element_name = "#{self.name} => #{key}"
      validator    = validator_for(key)
      validator.new(element_name, element_value).validate
    end

    def validator_for(key)
      default_validator = AARPCC::Types::String
      return default_validator if self.class.element_declarations.blank?
      element_declaration = self.class.element_declarations[key]
      return default_validator if element_declaration.blank?
      element_declaration.validator
    end



    class ElementDeclaration

      def initialize(name, options = {})
        @name    = name
        @options = options.with_indifferent_access
      end

      def optional?
        !!@options[:optional]
      end

      def validator
        @options[:validate_with] || AARPCC::Types::String
      end
    end
  end


  class List < Base

    class_attribute :element_type

    def self.validate_with(klass)
      self.element_type = klass
    end

    def initialize(name, value)
      super(name, value, ::Array)
    end

    def perform_custom_validation
      validator    = (self.class.element_type || AARPCC::Types::String)
      self.value.each{ |e| validator.new("#{self.name} => element", e).validate }
    end


  end

end