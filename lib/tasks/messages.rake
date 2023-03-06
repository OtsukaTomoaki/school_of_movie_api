namespace :messages do
  require_relative '../../app/batch/analysis/messages'

  desc 'Helloを表示するタスク'
  task say: :environment do
    message_analysis = Messages.new
    message_analysis.execute
  end
end
