# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
require File.expand_path("#{File.dirname(__FILE__)}/environment")
rails_env = ENV['RAILS_ENV'] || :development
set :environment, rails_env.to_sym

set :output, error: './log/crontab_error.log', standard: './log/crontab.log'

ENV.each { |k, v| env(k, v) } # これを追加
set :environment, :development

every 10.minute do
  rake "messages:say"
end

# Learn more: http://github.com/javan/whenever
