FROM ruby:3.2.0

# Install Node.js and Yarn
RUN apt-get update && apt-get install -y nodejs yarn

# Set up working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock before installing dependencies
COPY Gemfile Gemfile.lock ./

# Install the correct version of Bundler
RUN gem install bundler:2.4.22

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy package.json and yarn.lock
COPY package.json ./
COPY yarn.lock ./

# Install JS dependencies
RUN yarn install

# Copy the rest of the application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose the port
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "${PORT:-3000}"]

# Local dev
# CMD ["rails", "server", "-b", "0.0.0.0"]
