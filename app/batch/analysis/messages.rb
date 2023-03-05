class Messages
  require 'logger'

  def self.say
    puts "Test"
    logger = Logger.new(Rails.root.join('log', 'cron.log'))
    logger.info "cron job started at #{Time.now}"
  end

  def initialize
    puts "initialize"
  end

  def execute
    _execute
  end

  private
    def _execute
      p '_execute'
      p Message.count
      txt = '公務員だぞ、地方公務員。お前達が乗車しているのはグレートマジンガーか？ ダンガイオーか？ 自閉症児や不良少年が主人公のロボットアニメじゃないんだよ。分かっとるのか？ 本当に'
      p txt
    end
end
