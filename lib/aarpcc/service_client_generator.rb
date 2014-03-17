class AARPCC::ServiceClientGenerator

  def initialize(documentation_declaration, params = {})
    @documentation_declaration = documentation_declaration
    @params                    = params
  end

  def generate
    class_name     = @params[:class_name] || 'ServiceClient'
    file_name      = File.expand_path('../../../templates/service_client.rb', __FILE__)
    service_client = File.read(file_name)
    service_client = service_client.sub('___CLASS_NAME___', class_name)
    service_client = service_client.sub('___SERVICE_METHODS___', service_methods)
  end

  def service_methods
    io = StringIO.new
    @documentation_declaration.controller_classes.each{ |cc| process_controller_class(cc, io) }
    io.string
  end

  def process_controller_class(controller_class, io)
    decl = controller_class.aarpcc_declaration
    decl.action_classes.each do |name, action_class|
      io << "\n\n" << process_action(controller_class, name, action_class.aarpcc_declaration)
    end
  end

  def process_action(controller_class, name, action_declaration)
    controller_path = controller_class.to_s.sub(/Controller$/, '').to_s.split("::").map{ |s| s.underscore }.join("/")
    path            = "/#{controller_path}/#{name}"
    request_method  = action_declaration.get_request_method
    code            = <<-RUBY
      def #{name}(params = {}); #{request_method}('#{path}', params); end
    RUBY
    code.split("\n").map{ |l| l.sub(/^\s{4}/, '') }.join("\n")
  end

end