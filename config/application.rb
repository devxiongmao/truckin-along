require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TruckinAlong
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.autoload_paths += %W[#{config.root}/app/services]
    config.autoload_paths += %W[#{config.root}/app/validators]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.after_initialize do
      # Remove production check when ready
      unless Rails.env.test? || Rails.env.production?
        schedule_file = Rails.root.join("config/sidekiq.yml")
        if File.exist?(schedule_file)
          config = YAML.load_file(schedule_file)
          jobs = config["schedule"] || {}
          Sidekiq::Cron::Job.load_from_hash(jobs)
          puts "Cron jobs loaded: #{Sidekiq::Cron::Job.all.size}"
        end
      end
    end
  end
end
