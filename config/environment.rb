# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Borg::Application.initialize!

# Workaround for Bug in kickstrap-gem bootstrap-path needs to be added to less-path
# module KickstrapRails
#   class Engine < Rails::Engine
#     Rails.application.config.less.paths << File.join(config.root, 'vendor', 'assets','stylesheets','bootstrap')
#   end
# end
