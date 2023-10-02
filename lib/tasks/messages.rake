namespace :messages do
  require_relative '../analysis/messages'

  desc 'Helloを表示するタスク'
  task say: :environment do
    message_analysis = Analysis::Messages.new
    message_analysis.execute
  end
end
