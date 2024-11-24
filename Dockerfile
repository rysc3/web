# Base image
FROM ruby:3.2.0

# Install Node.js 14.x
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Bundler
RUN gem install bundler:2.4.22

# Install Ruby dependencies
RUN bundle install --jobs 4 --retry 3

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install Node.js dependencies
RUN yarn install --check-files

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Command to start the server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-3000}"]

# Local dev
# CMD ["rails", "server", "-b", "0.0.0.0"]
