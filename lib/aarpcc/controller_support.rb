module AARPCC::ControllerSupport

  #
  #
  #
  def self.included(controller_class)
    controller_class.class_eval do
      def self.acts_as_rpc_controller(&block)
        decl = ControllerDeclaration.new
        decl.instance_eval(&block)
        decl.apply_on(self)
      end
    end
  end


  #
  #
  #
  class ControllerDeclaration

    attr_reader :action_classes, :renderer_class, :access_logger, :critical_logger
  
    def initialize
      @action_classes   = {}.with_indifferent_access
      @renderer_class   = AARPCC::Renderer
      @access_logger    = Logger.new("#{Rails.root}/log/aarpcc_access.log")
      @critical_logger  = Logger.new("#{Rails.root}/log/aarpcc_critical.log")
    end
  
    def action(name, action_class)
      @action_classes[name] = action_class
    end
  
    def set_parameter_parser(parser_class)
    end
  
    def render_with(renderer_class)
      @renderer_class = renderer_class
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
        define_method(action_name) do
          AARPCC::Invoker.new(self, action_class).invoke
        end
      end
    end
  end

end