class Analysis::Messages
    require 'logger'
    def self.say
      puts "Test"
      logger = Logger.new(Rails.root.join('log', 'cron.log'))
      logger.info "cron job started at #{Time.now}"
    end
end