require_relative 'boot'
require 'csv'
require 'rails/all'

Bundler.require(*Rails.groups)

module Fax
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')
    config.active_job.queue_adapter = :sidekiq
  end
end
