acts_as_rpc_controller
======================

Support for building RPC services in Rails

## Installation
``` ruby
# Gemfile
gem 'acts_as_rpc_conroller', :git => 'https://github.com/kentorgbg/acts_as_rpc_controller'
```

``` ruby
# config/initializers/acts_as_rpc_controller.rb
ActionController::Metal.class_eval do
  include AARPCC::ControllerSupport
  include AARPCC::DocumentationSupport
end

Object.class_eval do
  include AARPCC::ActionSupport
end
```

## Basic use
``` ruby
# app/controllers/my_rpc_controller.rb
class MyRpcController < ActionController::Metal
  acts_as_rpc_controller do
    action :action_name_1, ActionImplementationClass1
    action :action_name_2, ActionImplementationClass2
    ...
  end
end
```

``` ruby
# app/actions/action_implementation_class_1.rb
class ActionImplementationClass1
  acts_as_rpc_action do
    description "An example RPC action"
    request_method :get
    parameter :parameter1
    parameter :parameter2
    returns   :result
  end
  
  # In the execute method, parameters can be accessed through the params hash. in this case
  # {:parameter1 => ..., :parameter2 => ...}
  def execute
    # Do something with params and return result
  end
end
```
