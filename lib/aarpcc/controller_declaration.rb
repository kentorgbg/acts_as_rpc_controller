class AARPCC::ControllerDeclaration

  attr_reader :action_classes

  def initialize
    @action_classes = {}.with_indifferent_access
  end

  def action(name, action_class)
    @action_classes[name] = action_class
  end

  def set_parameter_parser(parser_class)
  end

  def set_result_renderer(renderer_class)
  end

  def set_error_renderer(renderer_class)
  end

  def apply_on(controller_class)
    controller_class.cattr_accessor :aarpcc_declaration
    controller_class.aarpcc_declaration = self
    @action_classes.each do |name, klass|
      define_rails_action(controller_class, name, klass)
    end
  end

  def define_rails_action(controller_class, action_name, action_class)
    controller_class.class_eval do
      define_method(action_name){ aarpcc_invoke(action_class) }
    end
  end
end