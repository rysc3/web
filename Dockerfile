FROM ruby:3.2.0

# libsqlite3-dev so the sqlite3 gem builds against a system SQLite rather
# than relying on whatever the base image happens to ship.
#
# No Node and no Yarn: webpacker is commented out of the Gemfile, there is no
# execjs/uglifier/terser, nothing calls javascript_pack_tag, and no asset
# reads from node_modules. The JavaScript on this site is one plain Sprockets
# file. Installing a Node toolchain only added build time and a deprecated
# apt-key step that will eventually stop working.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gems first, so a source-only change does not reinstall them.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.4.22 && \
    bundle install --jobs 4 --retry 3

COPY . .

# Baked into the image for production. In development the bind mount shadows
# this and Sprockets compiles on demand, which is why dev never needed it.
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Shell form on purpose: the exec form does not expand ${PORT}, so the old
# exec-form CMD passed the literal string "${PORT:-3000}" as the port.
CMD bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
