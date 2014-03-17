module AARPCC::DocumentationSupport

  def self.included(controller_class)
    controller_class.class_eval do
      extend ClassMethods
    end
  end


  #
  #
  #
  module ClassMethods

    def acts_as_rpc_documentation(&block)
      decl = DocumentationDeclaration.new
      decl.instance_eval(&block)
      decl.apply_on(self)
    end
  end


  #
  #
  #
  module InstanceMethods

    def index
      redirect_to action: :api
    end

    def api
      self.response_body = ApiRenderer.new(self.class.aarpcc_documentation_declaration).to_html
    end

    def service_client
      self.headers['Content-Type'] = "text/plain"
      self.response_body = AARPCC::ServiceClientGenerator.new(self.class.aarpcc_documentation_declaration, params).generate
    end

    def render_api_on(html)
      html.h1{ html.text "API" }
    end
  end


  #
  #
  #
  class DocumentationDeclaration

    attr_reader :controller_classes

    def initialize
      @controller_classes = []
    end

    def rpc_controller(controller_class)
      @controller_classes << controller_class
    end

    def apply_on(controller_class)
      controller_class.cattr_accessor :aarpcc_documentation_declaration
      controller_class.aarpcc_documentation_declaration = self
      controller_class.instance_eval{ include InstanceMethods }
    end

  end


  #
  #
  #
  class ApiRenderer
    
    def initialize(documentation_declaration)
      @documentation_declaration = documentation_declaration
    end

    def to_html
      html = Canvas.new
      render_css_on(html)
      html.h1{ html.text "API" }
      html.ul do
        @documentation_declaration.controller_classes.each{ |cc| render_controller_documentation_on(html, cc) }
      end
      html.to_html
    end

    def render_css_on(html)
      html.style do
        html.text <<-CSS
          li.controller-documentation {
            list-style-type: none;
          }

          .controller-documentation li {
            list-style-type: none; 
          }
        CSS
      end
    end

    def render_controller_documentation_on(html, controller_class)
      html.li :class => 'controller-documentation' do
        html.h2{ html.text controller_class.to_s }
        html.ul do
          controller_class.aarpcc_declaration.action_classes.each do |name, action_class|
            render_action_documentation_on(html, name, action_class)
          end
        end
      end
    end

    def render_action_documentation_on(html, name, action_class)
      html.li{ html.h3{ html.text name } }
      html.ul do
        decl = action_class.aarpcc_declaration
        html.li{ html.text "<strong>Description:</strong> #{decl.get_description}" }
        html.li{ html.text "<strong>Request Method:</strong> #{decl.get_request_method.to_s.upcase}" }
        html.li do
          html.strong{ html.text "Parameters:" }
          html.ul do
            decl.parameter_declarations.each do |name, pdecl|
              render_parameter_declaration_on(html, pdecl)
            end
          end
        end
        html.li do
          html.strong{ html.text "Returns:" }
          html.ul{ render_parameter_declaration_on(html, decl.get_returns_declaration) }
        end
      end
    end

    def render_parameter_declaration_on(html, declaration)
      type = declaration.validator.class.to_s
      html.li{ html.text "#{declaration.name}: #{type}" }
    end
  end


  #
  #
  #
  class Canvas

    def initialize
      @io = StringIO.new
    end

    def to_html
      @io.string
    end

    def method_missing(name, *args, &block)
      tag(name, args.first, &block)
    end

    def tag(name, attributes, &block)
      attributes ||= {}
      if block
        open_tag(name, attributes)
        block.call
        close_tag(name)
      else
        simple_tag(name, attributes)
      end
    end

    def text(str)
      @io << str
    end


    private

    def open_tag(name, attributes)
      @io << "<" << name
      unless attributes.empty?
        @io << " " << attribute_list(attributes)
      end
      @io << ">"
    end

    def close_tag(name)
      @io << "</#{name}>"
    end

    def simple_tag(name, attributes)
      @io << "<" << name
      unless attributes.empty?
        @io << " " << attribute_list(attributes)
      end
      @io << " />"
    end

    def attribute_list(attributes)
      attributes.map{ |k, v| "#{k}=\"#{v}\"" }.join(" ")
    end
  end
end