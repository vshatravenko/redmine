FROM ruby:2.4
MAINTAINER lbellet@heliostech.fr

ENV APP_HOME=/home/app
ENV RAILS_ENV=production

RUN groupadd -r app --gid=1000
RUN useradd -r -m -g app -d /home/app --uid=1000 app

# RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update && apt-get install -y \
  libmysqlclient-dev \
  imagemagick git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/
COPY config/database.yml $APP_HOME/config/database.yml

# Install dependencies
RUN mkdir -p $APP_HOME/vendor/bundle
RUN bundle install --path vendor/bundle --without development test

# Copy the main application.
COPY . $APP_HOME

RUN chown -R app:app /home/app
USER app

# Expose port 8080 to the Docker host, so we can access it
# from the outside.
EXPOSE 8080
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["rails", "s", "-p", "8080", "-b", "0.0.0.0"]
