# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"

set :output, error: './log/crontab_error.log', standard: './log/crontab.log'
# TODO: 環境ごとの分岐をかく
set :environment, :development

ENV.each { |k, v| env(k, v) } # これを追加

every 10.minute do
  rake "messages:say"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
