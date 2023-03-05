namespace :messages do
  desc "Helloを表示するタスク"
  task say: :environment do
    logger = Logger.new(Rails.root.join('log', 'cron.log'))
    logger.info "cron job started at #{Time.now}!!!!"
  end
end
