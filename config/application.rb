require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Web
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.generators do |g|
      g.template_engine :haml
    end
  end
end

# Precompile all assets in the app/assets directory
# Rails.application.config.assets.precompile += Dir.glob('app/assets/**/*').reject { |f| File.directory?(f) }
# Rails.application.config.assets.precompile += %w( *.ttf *.woff *.svg *.eot )
