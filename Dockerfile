FROM ruby:3.2.0

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn

# Set up working directory
WORKDIR /app

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install dependencies, including devDependencies
RUN yarn install

# Copy the rest of the application code
COPY . .

# Install the correct version of Bundler
RUN gem install bundler:2.4.22

# Install gems
RUN bundle install --jobs 4 --retry 3

# Expose port 3000 (or the port you use for the Rails server)
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
