FROM ruby:3.2.0

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Yarn 
# RUN npm install -g yarn@<desired_version>

# Set up working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs

# Install the correct version of Bundler
RUN gem install bundler:2.2.33

# Copy Gemfile and Gemfile.lock to the container
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application code
COPY . .

# Expose port 3000 (or the port you use for the Rails server)
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]


# # Base image with Ruby and Node.js
# FROM ruby:2.7

# # Set up working directory
# WORKDIR /app

# # Install dependencies
# RUN apt-get update -qq && apt-get install -y nodejs

# # Copy Gemfile and Gemfile.lock to the container
# COPY Gemfile Gemfile.lock ./

# # Install gems
# RUN bundle install --jobs 4 --retry 3

# # Copy the rest of the application code
# COPY . .

# # Expose port 3000 (or the port you use for the Rails server)
# EXPOSE 3000

# # Start the Rails server
# CMD ["rails", "server", "-b", "0.0.0.0"]