FROM cpuguy83/ruby-mri
RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev openssl libssl-dev libyaml-dev libreadline-dev libxml2-dev libxslt1-dev
RUN gem install bundler && mkdir /opt/myapp
WORKDIR /opt/myapp
ENV RAILS_ENV production

# Add Gemfile stuff first as a build optimization
# This way the `bundle install` is only run when either Gemfile or Gemfile.lock is changed
# This is because `bundle install` can take a long time
# Without this optimization `bundle install` would run if _any_ file is changed within the project, no bueno
ADD Gemfile /opt/myapp/
ADD Gemfile.lock /opt/myapp/
RUN bundle install

# Any change to any file after this point (if not in .dockerignore) will cause the build cache to be busted here
# This includes changes to the Dockerfile itself
ADD . /opt/myapp
RUN rake assets:precompile # `config.assets.initialize_on_precompile = false` in application.rb
CMD exec unicorn_rails