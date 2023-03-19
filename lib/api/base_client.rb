module Api
  require 'json'
  require 'rest-client'

  class BaseClient
    def initialize(max_retry_count: 3, retry_sleep_seconds: 5)
      @max_retry_count = max_retry_count
      @retry_sleep_seconds = retry_sleep_seconds
    end

    private
    def get(url:, params:)
      url = "#{url}?#{URI.encode_www_form(params)}"

      response = nil
      @max_retry_count.times do |retry_count|
        begin
          p url
          response = RestClient.get(url)
          break if response.code == 200
        rescue RestClient::ExceptionWithResponse => e
          status_code = e.response.code.to_i
          body = e.response.body
          if (500..599).include?(status_code)
            puts "Server error #{e.response.body}"
          else
            Rails.logger.error("Error occurred during request: #{status_code} body: #{body}")
            return
          end
        end

        if retry_count == @max_retry_count - 1
          Rails.logger.error("Failed to get response after #{@max_retry_count} retries.")
          return nil
        end

        sleep(@retry_sleep_seconds)
      end

      JSON.parse(response.body) if response.present?
    end
  end
end