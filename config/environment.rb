# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Sanpo::Application.initialize!

# Enable Facebook callback to my server
#config.action_controller.allow_forgery_protection = false
