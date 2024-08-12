source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'puma', '~> 5.0'

# For database use; you might consider removing this if you are not using SQLite3.
gem 'sqlite3', '~> 1.4'

# For stylesheets
gem 'sass-rails', '>= 6'

# JavaScript and asset pipeline
# gem 'webpacker', '>= 4.0'
gem 'jsbundling-rails'
gem 'turbolinks', '~> 5'

# API building and JSON rendering
gem 'jbuilder', '~> 2.7'

# HAML templating and Bootstrap
gem 'haml-rails'
gem 'bootstrap', '~> 5.0'
gem 'jquery-rails'

# Markdown parsing
gem 'redcarpet'

# Optimizes boot time by caching
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Debugging tool
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Development tools
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  # System testing tools
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
end

# Windows-specific timezone data
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
