require_relative 'boot'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fax
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #config.time_zone = 'Central Time (US & Canada)'

    # Use a real queuing backend for Active Job (and separate queues per environment)
    Rails.application.config.active_job.queue_adapter = :async
    # config.active_job.queue_name_prefix = "fax_#{Rails.env}"
  end
end
