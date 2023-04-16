module Api
  module TheMovieDatabase
    require 'json'
    require 'rest-client'
    require_relative "#{Rails.root}/lib/api/base_client"

    class Client < Api::BaseClient
      BASE_URL = ENV['THE_MOVIE_DATABASE_URL'].freeze
      API_KEY = ENV['THE_MOVIE_DATABASE_API_KEY'].freeze
      HEADERS = { 'Content-Type': 'application/json;charset=utf-8' }.freeze

      def initialize
        super
      end

      def fetch_popular_list(page: 1, language: 'ja')
        params = {
          api_key: API_KEY,
          language: language,
          page: page,
        }
        url = "#{BASE_URL}/movie/popular"

        get(url: url, params: params)
      end

      def fetch_searched_list(page: 1, language: 'ja', query:)
        params = {
          api_key: API_KEY,
          language: language,
          page: page,
          query: query
        }
        url = "#{BASE_URL}/search/movie"

        get(url: url, params: params)
      end

      def fetch_movie_genres(language: 'ja')
        params = {
          api_key: API_KEY,
          language: language
        }
        url = "#{BASE_URL}/genre/movie/list"
        get(url: url, params: params)
      end
    end
  end
end