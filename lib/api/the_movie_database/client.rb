module Api
  module TheMovieDatabase
    require 'json'
    require 'rest-client'

    class Client
      BASE_URL = ENV['THE_MOVIE_DATABASE_URL'].freeze
      API_KEY = ENV['THE_MOVIE_DATABASE_API_KEY'].freeze
      HEADERS = { 'Content-Type': 'application/json;charset=utf-8' }.freeze

      def initialize

      end

      def fetch_popular_list(page: 1, language: 'ja')
        params = {
          api_key: API_KEY,
          language: language,
          page: page,
        }
        response = get(path: '/movie/popular', params: params)
        response
      end

      private

      MAX_RETRY_COUNT = 3
      RETRY_SLEEP_SECONDS = 5

      def get(path:, params:)
        url = "#{BASE_URL}#{path}" + '?' + URI.encode_www_form(params)

        response = nil
        MAX_RETRY_COUNT.times do |retry_count|
          begin
            p url
            response = RestClient.get(url)
            break if response.code == 200
          rescue RestClient::Exception => e
            Rails.logger.error("Error occurred during request: #{e} #{response.code} #{response.body}")
          end

          if retry_count == MAX_RETRY_COUNT - 1
            Rails.logger.error("Failed to get response after #{MAX_RETRY_COUNT} retries.")
            return nil
          end

          sleep(RETRY_SLEEP_SECONDS)
        end

        JSON.parse(response.body) if response.present?
      end
    end
  end
end