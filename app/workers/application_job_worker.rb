class ApplicationJobWorker
  include Sidekiq::Worker
  queue_as :default

  def perform(*args)
    raise NotImplementedError
  end

  def parse_arguments_to_deep_symbols(arguments_value)
    JSON.parse(
      arguments_value.to_json, symbolize_names: false
    ).deep_symbolize_keys
  end
end