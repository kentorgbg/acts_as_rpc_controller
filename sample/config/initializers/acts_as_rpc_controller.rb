ActionController::Metal.class_eval do
  include AARPCC::ControllerSupport
  include AARPCC::DocumentationSupport
end

Object.class_eval do
  include AARPCC::ActionSupport
end
