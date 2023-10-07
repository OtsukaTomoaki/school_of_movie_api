FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y libxslt-dev liblzma-dev patch build-essential libpq-dev nodejs default-mysql-client vim cron
RUN apt-get install libmecab2 libmecab-dev mecab mecab-ipadic mecab-ipadic-utf8 mecab-utils

RUN mkdir /school_of_movie_api

RUN gem install nokogiri --platform=ruby
RUN gem install solargraph
RUN gem install mecab natto

RUN bundle config set force_ruby_platform true

WORKDIR /school_of_movie_api

COPY Gemfile /school_of_movie_api/Gemfile
COPY Gemfile.lock /school_of_movie_api/Gemfile.lock

RUN bundle install
RUN rails active_storage:install

COPY . /school_of_movie_api

# RUN bundle exec whenever --update-crontab
RUN export MECAB_PATH=/usr/lib/aarch64-linux-gnu/libmecab.so.2
