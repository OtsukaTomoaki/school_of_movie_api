FROM ruby:3.1.2

RUN apt-get update -qq && apt-get install -y libxslt-dev liblzma-dev patch build-essential libpq-dev nodejs default-mysql-client vim

RUN mkdir /project_manage_api

RUN gem install nokogiri --platform=ruby
RUN bundle config set force_ruby_platform true

WORKDIR /project_manage_api

COPY Gemfile /project_manage_api/Gemfile
COPY Gemfile.lock /project_manage_api/Gemfile.lock

RUN bundle install
RUN rails active_storage:install
COPY . /project_manage_api