module AARPCC; end

require 'aarpcc/validators.rb'
require 'aarpcc/errors.rb'
require 'aarpcc/action_support.rb'
require 'aarpcc/controller_declaration.rb'
require 'aarpcc/invoker.rb'
require 'aarpcc/controller_support.rb'
require 'aarpcc/integration_test_support.rb'
require 'aarpcc/service_client_generator.rb'
require 'aarpcc/documentation_support.rb'


#class AARPCC::Railtie < Rails::Railtie
#
#  initializer 'aarpcc_layout.add_paths' do |app|
#    app.paths["app/views"] << ""
#  end
#end