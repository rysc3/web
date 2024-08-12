FROM ruby:3.2.0

# Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn

# Set up working directory
WORKDIR /app

# Install the correct version of Bundler
RUN gem install bundler:2.4.22

# Copy Gemfile and Gemfile.lock to the container
COPY Gemfile Gemfile.lock ./

# Install dependencies 
RUN yarn install

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application code
COPY . .

# Expose port 3000 (or the port you use for the Rails server)
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
