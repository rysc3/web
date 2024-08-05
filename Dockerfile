# Use the official Ruby image
FROM ruby:3.2.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn

# Set working directory
WORKDIR /app

# Install the correct version of Bundler
RUN gem install bundler:2.4.1

# Copy the Gemfile and Gemfile.lock to the container
COPY Gemfile Gemfile.lock ./

# Install gems, skipping development and test
RUN bundle install --jobs 4 --retry 3 --without development test

# Copy the rest of the application code
COPY . .

# Precompile assets
# RUN bundle exec rake assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the Rails server in production mode
CMD ["rails", "server", "-e", "production", "-b", "0.0.0.0"]
