FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y libxslt-dev liblzma-dev patch build-essential libpq-dev nodejs default-mysql-client vim cron

RUN mkdir /funny_cats_api

RUN gem install nokogiri --platform=ruby
RUN bundle config set force_ruby_platform true

WORKDIR /funny_cats_api

COPY Gemfile /funny_cats_api/Gemfile
COPY Gemfile.lock /funny_cats_api/Gemfile.lock

RUN bundle install
RUN rails active_storage:install

COPY . /funny_cats_api

RUN bundle exec whenever --update-crontab
