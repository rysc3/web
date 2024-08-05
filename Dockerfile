# Use the official Ruby image
FROM ruby:3.2.0

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install the correct version of Bundler
RUN gem install bundler:2.4.1

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3 --without development test

# Copy the rest of the application code
COPY . .

# Precompile assets
# RUN bundle exec rake assets:precompiledc up'

# Expose port 3000
EXPOSE 3000

# Start the Rails server in production mode
CMD ["rails", "server", "-e", "production", "-b", "0.0.0.0"]
